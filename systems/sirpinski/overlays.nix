{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      gotosocial = prev.gotosocial.overrideAttrs (old: {
        version = "0.22.1";
        src = prev.fetchFromCodeberg {
          owner = "superseriousbusiness";
          repo = "gotosocial";
          tag = "v0.22.1";
          hash = "sha256-fRMQISOYf0rGcnNBpdlDeYWO0vvVwW0UPXdeT1y0+Ec=";
        };
      });
    })
  ];
}
