{pkgs, ...}: {
  services.keycloak = {
    database = {
      username = "keycloak";
      name = "keycloak";
      host = "/run/postgresql";
      createLocally = true;
    };
    plugins = with pkgs; [
      junixsocket-common
      junixsocket-native-common
    ];
    settings = {
      hostname = "https://id.nullvoid.space";
      http-port = 8084;
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
      # extraConfig = ''
      #   ssl_client_certificate /etc/certificates/authenticated_origin_pull_ca.pem;
      #   ssl_verify_client on;
      #   ${realIpsFromList cfipv4}
      #   ${realIpsFromList cfipv6}
      #   real_ip_header CF-Connecting-IP;
      # '';
    };
  };
}
