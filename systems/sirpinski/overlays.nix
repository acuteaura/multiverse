{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      gotosocial = prev.gotosocial.overrideAttrs (old: {
        version = "0.22.0";
        src = prev.fetchFromCodeberg {
          owner = "superseriousbusiness";
          repo = "gotosocial";
          tag = "v0.22.0";
          hash = "sha256-rslzi9WqPqN/wm9PN6SWdXtLdMRJJV6Hhb3whJ0RicU=";
        };
      });
    })
  ];
}
