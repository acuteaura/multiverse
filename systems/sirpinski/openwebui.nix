{...}: {
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
    };
  };

  services.open-webui = {
    enable = true;
    environment = {
      WEBUI_URL = "https://owui.atlas-ide.ts.net";
    };
  };
}
