{
  pkgs,
  lib,
  ...
}: {
  services.nginx = let
    defaultListenIPv4 = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
    ];
    defaultListenIPv6 = [
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
    ];
  in {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # virtualHosts."78.47.161.199" = {
    #   listen = defaultListenIPv4 ++ defaultListenIPv6 ++ cloudflareListenIPv4 ++ cloudflareListenIPv6;
    #   rejectSSL = true;
    #   default = true;
    #   locations."/" = {
    #     return = "404";
    #   };
    # };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "past.tree1213@cognitive-antivirus.net";
      reloadServices = ["nginx"];
    };
    certs = {
      "id.nullvoid.space" = {
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = "/etc/cloudflare.env";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    49152
  ];
}
