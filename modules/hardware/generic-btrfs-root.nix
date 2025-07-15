{ config, lib, ... }:

with lib;
let
  cfg = config.index.hardware.disk.generic-btrfs-root;
  commonMountOptions = [
    "noatime"
    "compress=zstd"
    # hardening options
    "nosuid"
    "nodev"
  ];
in
{
  options.index.hardware.disk.generic-btrfs-root = {
    enable = mkEnableOption "Enable generic btrfs root";
    disk = mkOption {
      type = types.str;
      default = "/dev/vda";
    };

    mbrSupport = mkEnableOption "MBR support";
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        system = {
          type = "disk";
          device = cfg.disk;
          content = {
            type = "gpt";
            partitions =
              {
                ESP = {
                  priority = if cfg.mbrSupport then 1 else 0;
                  name = "ESP";
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "nodev"
                      "noexec"
                      "nosuid"
                    ];
                  };
                };

                ROOT = {
                  size = "100%";
                  name = "rootfs";
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      # Subvolume name is different from mountpoint
                      "/rootfs" = {
                        mountpoint = "/";
                        mountOptions = commonMountOptions;
                      };
                      "/nix" = {
                        mountOptions = commonMountOptions;
                        mountpoint = "/nix";
                      };
                    };
                  };
                };
              }
              // (lib.optionalAttrs (cfg.mbrSupport) {
                BOOT = {
                  size = "1M";
                  type = "EF02"; # for grub MBR
                  priority = 0;
                };
              });
          };
        };
      };
    };
  };
}
