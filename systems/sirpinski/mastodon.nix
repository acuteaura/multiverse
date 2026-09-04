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

  services.nginx = {
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

  services.opensearch.enable = true;
  services.mastodon.elasticsearch.host = "127.0.0.1";
}
