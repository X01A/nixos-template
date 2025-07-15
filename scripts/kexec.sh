#!/usr/bin/env bash

set -ex

if [[ "$#" != "1" ]]; then
	>&2 echo "Usage: $0 [target]"
	>&2 echo "Example: $0 root@example.com"
	exit 1
fi

target=$1

ssh $target -- wget https://github.com/nix-community/nixos-images/releases/download/nixos-23.11/nixos-kexec-installer-x86_64-linux.tar.gz
ssh $target -- tar zxvf nixos-kexec-installer-x86_64-linux.tar.gz
ssh $target -- "sync"
ssh $target -- "cd kexec && ./run"

sleep 3
while true; do
    ssh $target -- "exit 0"
    if [ "$?" == "0" ]; then
        break
    else
        sleep 1
    fi
done
