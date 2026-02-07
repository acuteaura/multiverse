{pkgs, ...}: {
  services.tailscale.serve = {
    enable = true;
    services = {
      owui = {
        endpoints = {
          "tcp:443" = "http://localhost:8080";
          "tcp:80" = "http://localhost:8080";
        };
        advertised = true;
      };
      tavern = {
        endpoints = {
          "tcp:443" = "http://localhost:8045";
          "tcp:80" = "http://localhost:8045";
        };
        advertised = true;
      };
    };
  };

  services.open-webui = {
    enable = true;
    environment = {
      WEBUI_URL = "https://owui.atlas-ide.ts.net";
    };
  };

  services.sillytavern = let
    sillytavernConfig = pkgs.writeText "sillytavern-config.yaml" ''
      whitelistMode: true
      enableForwardedWhitelist: true
      whitelist:
        - "::1"
        - "127.0.0.1"
        - "100.64.0.0/10"
      enableUserAccounts: true
      thumbnails:
        enabled: true
        format: png
        quality: 100
        dimensions:
          bg:
            - 240
            - 135
          avatar:
            - 864
            - 1280
    '';
  in {
    enable = true;
    port = 8045;
    listen = true;
    whitelist = true;
    configFile = "${sillytavernConfig}";
  };
}
