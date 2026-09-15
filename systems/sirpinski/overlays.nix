{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      # not backported to nixos-26.05
      gotosocial = prev.gotosocial.overrideAttrs (old: {
        version = "0.22.1";
        src = prev.fetchFromCodeberg {
          owner = "superseriousbusiness";
          repo = "gotosocial";
          tag = "v0.22.1";
          hash = "sha256-fRMQISOYf0rGcnNBpdlDeYWO0vvVwW0UPXdeT1y0+Ec=";
        };
      });
      mastodon = prev.mastodon.override {
        srcOverride = prev.fetchFromGitHub {
          owner = "mastodon";
          repo = "mastodon";
          rev = "v4.6.8";
          hash = "sha256-fDbQunhcpnMnIufEX2oRH9vulsHjtlR95boj0M2O3CQ=";
          passthru = {
            version = "4.6.8";
            yarnHash = "sha256-VlOG91ZuO+1UXTbtwIrYUbqHjmSfPSfLhrf4TxCJqJ0=";
            inherit (prev.mastodon.src) yarnMissingHashes;
          };
        };
      };
    })
  ];
}
