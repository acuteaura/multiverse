_: {
  virtualisation.quadlet.networks.keycloak = {};

  services.keycloak = {
    database = {
      username = "keycloak";
      name = "keycloak";
      host = "/run/postgresql";
      createLocally = false;
    };
    plugins = with pkgs; [
      junixsocket-common
      junixsocket-native-common
    ];
    settings = {
      hostname = "https://id.nullvoid.space";
      http-port = 8084;
      db-schema = "keycloak";
    }
  };

  virtualisation.quadlet.containers.keycloak-postgres = {
    containerConfig = {
      name = "keycloak-postgres";
      hostname = "keycloak-postgres";
      image = "docker.io/library/postgres:16.10";
      volumes = [
        "/data/keycloak/postgres:/var/lib/postgresql/data:U"
      ];
      environmentFiles = [
        "/etc/keycloak.env"
      ];
      networks = ["keycloak.network"];
    };
    unitConfig = {
      After = ["network.target"];
      Wants = ["network.target"];
      RequiresMountsFor = [
        "/data"
      ];
      ConditionPathExists = ["/etc/keycloak.env"];
    };
  };

  virtualisation.quadlet.containers.keycloak = {
    containerConfig = {
      name = "keycloak";
      hostname = "keycloak";
      image = "quay.io/aurelias/keycloak:e0b70f8074a1a4985bc820cf128b4b4f2c4e7d15@sha256:3d190ad8ba52ba20be8fabb5fe77f957e2df001d57b7dc1fe7caeef5b1c24ad1";
      environments = {
        "KC_DB" = "postgres";
        "KC_DB_URL_HOST" = "keycloak-postgres";
        "KC_DB_URL_DATABASE" = "postgres";
        "KC_DB_USERNAME" = "postgres";
        "KC_HOSTNAME" = "https://id.nullvoid.space";
        "JAVA_OPTS_APPEND" = "-Djava.net.preferIPv4Stack=false -Djava.net.preferIPv6Addresses=true";
      };
      environmentFiles = [
        "/etc/keycloak.env"
      ];
      networks = ["keycloak.network"];
      publishPorts = [
        "127.0.0.1:8080:8080"
      ];
    };
    unitConfig = {
      After = [
        "network.target"
        "keycloak-postgres.service"
      ];
      Wants = [
        "network.target"
        "keycloak-postgres.service"
      ];
      ConditionPathExists = ["/etc/keycloak.env"];
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
  };


}
