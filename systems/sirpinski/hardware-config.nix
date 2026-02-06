{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.kernelParams = ["console=tty"];
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme" "virtio_gpu"];

  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bootsector = {
              size = "1M";
              type = "EF02";
              attributes = [0];
            };
            boot = {
              size = "2G";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "sirpinski";
              };
            };
          };
        };
      };
    };
    zpools.sirpinski = {
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
          options = {};
          mountpoint = "/";
        };
        "nix" = {
          type = "zfs_fs";
          options.mountpoint = "/nix";
          mountpoint = "/nix";
        };
        "home" = {
          type = "zfs_fs";
          options.mountpoint = "/home";
          mountpoint = "/home";
      };
    };
  };
}
