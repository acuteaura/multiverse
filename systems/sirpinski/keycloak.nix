{
  pkgs,
  config,
  ...
}: {
  services.keycloak = {
    enable = true;
    database = {
      username = "keycloak";
      name = "keycloak";
      host = "/run/postgresql";
    };
    # fetchMavenArtifact outputs a symlink at share/java/*.jar, but Keycloak's
    # plugin installer only picks up files matching `find -type f`, so the jar
    # is silently skipped if we pass the package itself. `.jar` is the
    # passthru attribute pointing directly at the underlying fetched file.
    # See https://github.com/NixOS/nixpkgs/pull/472219.
    plugins = with pkgs; [
      junixsocket-common.jar
      junixsocket-native-common.jar
    ];
    settings = {
      hostname = "https://id.nullvoid.space";
      http-port = 8084;
      http-enabled = true;
      proxy-headers = "xforwarded";
      db-schema = "keycloak";
    };
  };

  services.nginx = let
    kcPort = config.services.keycloak.settings.http-port;
  in {
    virtualHosts."id.nullvoid.space" = {
      forceSSL = true;
      kTLS = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString kcPort}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          client_max_body_size 256M;
          allow 100.64.0.0/10;
          allow 89.1.7.228;
          deny all;
        '';
      };
      locations."/realms/nvs" = {
        proxyPass = "http://127.0.0.1:${toString kcPort}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          client_max_body_size 256M;
        '';
      };
      locations."/realms/nullvoid.space" = {
        proxyPass = "http://127.0.0.1:${toString kcPort}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          client_max_body_size 256M;
        '';
      };
      locations."/resources" = {
        proxyPass = "http://127.0.0.1:${toString kcPort}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
        '';
      };
      locations."/realms/nvs/metrics" = {
        extraConfig = ''
          deny all;
        '';
      };
      locations."/realms/nullvoid.space/metrics" = {
        extraConfig = ''
          deny all;
        '';
      };
    };
  };
}
