{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.grub.device = "/dev/sda";

  boot.kernelParams = ["console=tty"];
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme" "virtio_gpu"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/64f6fb02-4fed-4836-a33b-86e8993afdfa";
    fsType = "ext4";
  };
}
