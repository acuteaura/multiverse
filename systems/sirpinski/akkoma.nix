{pkgs, ...}: {
  systemd.tmpfiles.rules = [
    "d /var/cache/nginx/cache/akkoma-media-cache 0700 nginx nginx -"
  ];

  services.nginx.commonHttpConfig = ''
    proxy_cache_path /var/cache/nginx/cache/akkoma-media-cache
      levels= keys_zone=akkoma_media_cache:16m max_size=16g
      inactive=1y use_temp_path=off;
  '';

  systemd.services.akkoma.wantedBy = pkgs.lib.mkForce [];

  services.akkoma = {
    enable = true;
    config = {
      ":pleroma" = with (pkgs.formats.elixirConf {}).lib; {
        ":instance" = {
          name = "nv_";
          description = "akkoma on nullvoid.space";
          email = "aurelia@nullvoid.space";
          registrations_open = false;
          invites_enabled = true;
          federating = true;
          public = false;
        };
        ":media_proxy" = {
          enabled = true;
          proxy_opts.redirect_on_failure = true;
        };
        ":media_preview_proxy" = {
          enabled = true;
          thumbnail_max_width = 1920;
          thumbnail_max_height = 1080;
        };
        ":mrf".policies = map mkRaw ["Pleroma.Web.ActivityPub.MRF.SimplePolicy"];
        ":mrf_simple" = {};

        "Pleroma.Web.Endpoint" = {
          url.host = "akkoma.dip0.e-ipconnect.nullvoid.space";
        };
      };
    };
    nginx = {
      enableACME = true;
      forceSSL = true;
      locations."/proxy" = {
        proxyPass = "http://unix:/run/akkoma/socket";

        extraConfig = ''
          proxy_cache akkoma_media_cache;

          # Cache objects in slices of 1 MiB
          slice 1m;
          proxy_cache_key $host$uri$is_args$args$slice_range;
          proxy_set_header Range $slice_range;

          # Decouple proxy and upstream responses
          proxy_buffering on;
          proxy_cache_lock on;
          proxy_ignore_client_abort on;

          # Default cache times for various responses
          proxy_cache_valid 200 1y;
          proxy_cache_valid 206 301 304 1h;

          # Allow serving of stale items
          proxy_cache_use_stale error timeout invalid_header updating;
        '';
      };
    };
  };
}
