{ config, ... }:

{
  deployment.targetHost = "19.89.89.64";

  indexyz.environment.base.enable = true;
  indexyz.environment.efi.enable = true;
  indexyz.services.ssh.enable = true;

  index.hardware.qemu-guest.enable = true;
  index.hardware.disk.generic-btrfs-root = {
    enable = true;
    mbrSupport = true;
    disk = "/dev/vda";
  };

  networking = {
    hostName = "example-host";
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks = {
    wan = {
      matchConfig = {
        MACAddress = "00:00:00:00:00:00";
      };
      address = [ "19.89.89.64/24" ];
      routes = [ { Gateway = "19.89.89.1"; } ];
    };
  };
}
