{...}: {
  services.cyac = {
    enable = true;
    kernel = "kvm"; # nested KVM is available on this host
    proxy = {
      openFirewall = true;
    };
  };
}
