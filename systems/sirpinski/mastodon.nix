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
    configureNginx = false;
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

    # redirects, relocate block if anything else ends up here
    virtualHosts.${federationDomain} = {
      forceSSL = true;
      kTLS = true;
      enableACME = true;
      locations."/.well-known/host-meta".return = "301 https://${webDomain}$request_uri";
      locations."/.well-known/webfinger".return = "301 https://${webDomain}$request_uri";
      locations."/.well-known/nodeinfo".return = "301 https://${webDomain}$request_uri";
      locations."/".return = "301 https://${webDomain}";
    };
  };
}
