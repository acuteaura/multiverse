{pkgs, ...}: let
  auraSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmjGIsSO9jE85xNPzzp0AWfOSXVL4qQ3cuXeKCvxe+q";
in {
  imports = [
    ./hardware-config.nix
  ];

  universe.base.enable = true;
  # universe.base defaults to an EOL kernel; this pins 6.18 + zfs_2_4
  universe.kernel.enable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "perimeter";
  networking.domain = "nullvoid.space";
  # required by zfs, must be unique per host
  networking.hostId = "9f3c1a74";

  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = true;
      };
      address = [
        "5.231.118.237/24"
      ];
      routes = [
        {
          Gateway = "5.231.118.1";
        }
      ];
      dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "${auraSSHKey}"
  ];

  users.users.aurelia = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "${auraSSHKey}"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "-d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
