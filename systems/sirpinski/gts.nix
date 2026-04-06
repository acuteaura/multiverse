{...}: {
  services.gotosocial = {
    enable = true;
    settings = {
      application-name = "global trade station";
      host = "gts.foxsnuggl.es";
      bind-address = "127.0.0.1";
      db-type = "postgres";
      db-address = "/run/postgresql";
      db-database = "gotosocial";
      db-user = "gotosocial";
      port = 8082;
      protocol = "https";
      storage-local-base-path = "/var/lib/gotosocial/storage";
      accounts-allow-custom-css = true;
      accounts-max-profile-fields = 12;
      advanced-rate-limit-exceptions = ["89.1.7.228/32"];
    };
  };

  services.nginx.virtualHosts."gts.foxsnuggl.es" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 100M;
      '';
    };
  };
}
