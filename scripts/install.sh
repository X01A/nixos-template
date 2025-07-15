#!/usr/bin/env bash

# MIT Licensed - 2021 Zhaofeng Li
# Modify @5aaee9

set -euo pipefail

log() {
	>&2 echo -ne "\033[1m\033[34m*** "
	>&2 echo -n "$@"
	>&2 echo -e "\033[0m"
}

error() {
	>&2 echo -ne "\033[1m\033[31m*** Error: "
	>&2 echo -n "$@"
	>&2 echo -e "\033[0m"
}

nix() {
	(run env nix --experimental-features nix-command "$@")
}

run() {
	set -x
	exec -- "$@"
}

ssh() {
	(run env ssh $NIX_SSHOPTS $@)
}

scp() {
	(run env scp $NIX_SSHOPTS $@)
}

copy() {
  if [[ "${COPY_LOCAL:-}" = "true" ]] ; then
    COPY_ARGS=""
  else
    COPY_ARGS="--substitute-on-destination"
  fi

  (run env nix copy $COPY_ARGS $@)
}

finish() {
	ret=$?

	set +eu

	log "Cleaning up..."

	if [[ -n "${target}" && -n "${tmpdir}" ]]; then
		log "Disconnecting from host..."
		run ssh -o "ControlPath ${tmpdir}/ssh.sock" -O exit "${target}"
	fi

	rm -rf "${tmpdir}"

	if [[ "${ret}" != "0" ]]; then
		log "Return Code -> ${ret}"
	fi

	exit $ret
}

trap finish EXIT

if [[ "$#" != "2" ]]; then
	>&2 echo "Usage: $0 [name of host] [mountpoint]"
	>&2 echo "Example: $0 somehost /mnt"
	exit 1
fi

name=$1
mountpoint=$2

if [[ "${mountpoint}" = "" || "${mountpoint}" = "/" ]]; then
	error "Mountpoint cannot be empty or root!"
	exit 1
fi

tmpdir=$(mktemp -d)
log "Our temporary directory is ${tmpdir}"

# The argument expansion for NIX_SSHOPTS is broken and we can't
# directly put "quoted arguments with spaces" :(
echo -e "ControlMaster auto\nControlPath ${tmpdir}/ssh.sock\nControlPersist 30m" > $tmpdir/ssh_config
export NIX_SSHOPTS="-F ${tmpdir}/ssh_config"

log "Getting SSH target..."
target=$(run colmena eval -E "{ nodes, ... }: with nodes.\"$name\".config.deployment; \"ssh://\${targetUser}@\${targetHost}:\${builtins.toString targetPort}\"" | jq -r)

log "~~~~~~"
log "Deploying to ${target} on mountpoint ${mountpoint}"
log "~~~~~~"

log "Evaluating configuration... "
drv=$(run colmena --legacy-flake-eval --impure eval --instantiate -E "{ nodes, ... }: nodes.\"$name\".config.system.build.toplevel")
log "-> ${drv}"

log "Building configuration..."
system=$(run nix-build $drv)
log "-> ${system}"

log "Obtaining a persistent connection..."
ssh "${target}" -v true
log "-> Success"

FOUND_RO_STORE=$(ssh "${target}" -- bash -c \'test -d /nix/.ro-store\; echo \$?\')

if [ "$FOUND_RO_STORE" != "0" ]; then
  log "ERROR: not found read only store, skip install system"
  exit 1
fi

if [ "${DISKO_MOUNT_ONLY:-}" = "true" ]; then
	export SKIP_DISKO_PROCESS="true"
	diskoScriptDrv=$(run colmena --legacy-flake-eval --impure eval --instantiate -E "{ nodes, ... }: nodes.\"$name\".config.system.build.mount")
	diskoConfig=$(run nix-build $diskoScriptDrv)

  copy --to "${target}" "${diskoConfig}"
  log "-> Success"
  ssh "${target}" -- "${diskoConfig}/bin/disko-mount"
fi

if [ "${SKIP_DISKO_PROCESS:-}" = "" ]; then
  log "Building Disko Config"
  diskoScriptDrv=$(run colmena --legacy-flake-eval --impure eval --instantiate -E "{ nodes, ... }: nodes.\"$name\".config.system.build.diskoScript")
  diskoConfig=$(run nix-build $diskoScriptDrv)
  log "-> Success"
  log "Push create disk script"
  if [ "${DISKO_SKIP_COPY_BINARY:-}" = "" ]; then
    copy --to "${target}" "${diskoConfig}"
    log "-> Success"
    ssh "${target}" -- "${diskoConfig}"
  else
    dd if="${diskoConfig}" | ssh "${target}" "dd of=disko.sh"
    ssh "${target}" -- "bash disko.sh"
  fi
fi

log "Pushing configuration..."
copy --to "${target}?remote-store='local?root=${mountpoint}'" "${system}"
log "-> Pushed"

log "Activating configuration..."
ssh "${target}" -- "mkdir -p ${mountpoint}/etc && touch ${mountpoint}/etc/NIXOS && nix-env --store ${mountpoint} --profile ${mountpoint}/nix/var/nix/profiles/system --set ${system} && NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root ${mountpoint} -- /run/current-system/bin/switch-to-configuration boot"

if [ "${SKIP_REBOOT_TARGET:-}" = "" ]; then
  log "Rebooting target host..."
  ssh "${target}" -- "reboot"
fi
log "All done!"
