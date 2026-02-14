{pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    acceptTerms = true;
    defaults.email = "past.tree1213@cognitive-antivirus.net";
  };

  services.nginx = {
    enable = true;

    clientMaxBodySize = "16m";
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    package = pkgs.nginxStable.override {
      withSlice = true;
    };

    appendHttpConfig = ''
      aio threads;
      proxy_max_temp_file_size 0;
    '';

    eventsConfig = ''
      accept_mutex off;
      worker_connections 2048;
      multi_accept on;
    '';

    appendConfig = ''
      worker_processes auto;
    '';

    commonHttpConfig = ''
      proxy_cache_path /var/cache/nginx/cache/akkoma-media-cache
        levels= keys_zone=akkoma_media_cache:16m max_size=16g
        inactive=1y use_temp_path=off;
    '';

    virtualHosts."_" = {
      rejectSSL = true;
      default = true;
      locations."/" = {
        return = "404";
      };
    };
  };
}
