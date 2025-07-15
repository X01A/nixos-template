{ config, lib, ... }:

with lib;
let
  cfg = config.index.hardware.qemu-guest;
in
{
  options.index.hardware.qemu-guest = {
    enable = mkEnableOption "Enable hardware qemu-guest";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;

    boot = {
      extraModulePackages = [ ];
      initrd = {
        availableKernelModules = [
          "uhci_hcd"
          "ehci_pci"
          "ahci"
          "virtio_pci"
          "virtio_scsi"
          "sd_mod"
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "9p"
          "9pnet_virtio"
        ];
        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
          "virtio_gpu"
        ];
      };
    };
  };
}
