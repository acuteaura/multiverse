{...}: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.foxsnuggl.es";
      listen-http = "8083";
    };
  };

  services.nginx.virtualHosts."ntfy.foxsnuggl.es" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8083";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
