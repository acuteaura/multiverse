{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = ["console=tty"];
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme" "virtio_gpu"];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/227C-A484";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/64f6fb02-4fed-4836-a33b-86e8993afdfa";
    fsType = "ext4";
  };
}
