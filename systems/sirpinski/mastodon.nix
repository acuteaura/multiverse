{
  config,
  lib,
  ...
}: let
  federationDomain = "problematic.solutions";
  webDomain = "social.problematic.solutions";
  streamingProcesses = 1;
in {
  services.mastodon = {
    enable = true;
    localDomain = federationDomain;
    extraConfig.WEB_DOMAIN = webDomain;
    redis.createLocally = true;
    configureNginx = true;
    inherit streamingProcesses;
    database = {
      createLocally = true;
      host = "/run/postgresql";
      name = "mastodon";
      user = "mastodon";
    };
    smtp = {
      createLocally = true;
      fromAddress = "mastodon@${webDomain}";
    };
  };

  users.groups.${config.services.mastodon.group}.members = [ config.services.nginx.user ];

  services.nginx = {
    upstreams.mastodon-streaming = {
      extraConfig = "least_conn;";
      servers = builtins.listToAttrs (
        map (i: {
          name = "unix:/run/mastodon-streaming/streaming-${toString i}.socket";
          value = {};
        }) (lib.range 1 streamingProcesses)
      );
    };

    virtualHosts.${webDomain} = {
      root = "${config.services.mastodon.package}/public/";
      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        client_max_body_size 100m;
      '';

      locations."/system/".alias = "/var/lib/mastodon/public-system/";

      locations."/" = {
        tryFiles = "$uri @proxy";
      };

      locations."@proxy" = {
        proxyPass = "http://unix:/run/mastodon-web/web.socket";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };

      locations."/api/v1/streaming" = {
        proxyPass = "http://mastodon-streaming";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    virtualHosts.${federationDomain} = {
      forceSSL = true;
      kTLS = true;
      enableACME = true;
      locations."/.well-known/host-meta" = {
        return = "301 https://${webDomain}$request_uri";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."/.well-known/webfinger" = {
        return = "301 https://${webDomain}$request_uri";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."/.well-known/nodeinfo" = {
        return = "301 https://${webDomain}$request_uri";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."/" = {
        return = "301 https://${webDomain}";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };

  services.opensearch.enable = true;
  services.mastodon.elasticsearch.host = "127.0.0.1";
}
