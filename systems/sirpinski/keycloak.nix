{pkgs, ...}: {
  services.keycloak = {
    enable = true;
    database = {
      username = "keycloak";
      name = "keycloak";
      host = "/run/postgresql/.s.PGSQL.5432";
    };
    plugins = with pkgs; [
      junixsocket-common
      junixsocket-native-common
    ];
    settings = {
      hostname = "https://id.nullvoid.space";
      http-port = 8084;
      http-enabled = true;
      proxy-headers = "xforwarded";
    };
  };

  services.nginx = {
    virtualHosts."id.nullvoid.space" = {
      forceSSL = true;
      kTLS = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 256M;
          allow 100.64.0.0/10;
          allow 89.1.7.228;
          deny all;
        '';
      };
      locations."/realms/nvs" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 256M;
        '';
      };
      locations."/resources" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
      locations."/realms/nvs/metrics" = {
        extraConfig = ''
          deny all;
        '';
      };
    };
  };
}
