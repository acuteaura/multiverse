{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = ["console=tty"];
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme" "virtio_gpu"];

  boot.supportedFilesystems.zfs = true;
  boot.zfs.forceImportRoot = false;

  disko = {
    devices = {
      disk = {
        main = {
          device = "/dev/sda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              esp = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "perimeter";
                };
              };
            };
          };
        };
      };

      zpool.perimeter = {
        type = "zpool";
        rootFsOptions = {
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };
          "nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          "home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
