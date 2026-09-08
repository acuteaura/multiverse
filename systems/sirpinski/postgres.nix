{pkgs, lib, ...}: {
  services.postgresql = {
    package = pkgs.postgresql_14;

    settings = {
      "max_connections" = "200";
      "shared_buffers" = "4GB";
      "effective_cache_size" = "12GB";
      "maintenance_work_mem" = "1GB";
      "checkpoint_completion_target" = "0.9";
      "wal_buffers" = "16MB";
      "default_statistics_target" = "100";
      "random_page_cost" = "1.1";
      "effective_io_concurrency" = "200";
      "work_mem" = "127100kB";
      "huge_pages" = "try";
      "jit" = "off";
      "min_wal_size" = "1GB";
      "max_wal_size" = "4GB";
      "max_worker_processes" = "8";
      "max_parallel_workers_per_gather" = "4";
      "max_parallel_workers" = "8";
      "max_parallel_maintenance_workers" = "4";
    };

    enable = true;
    ensureDatabases = ["gotosocial" "keycloak" "mastodon"];
    ensureUsers = [
      {
        name = "gotosocial";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
      {
        name = "keycloak";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
      {
        name = "mastodon";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root        postgres
      superuser_map      postgres    postgres
      superuser_map      akkoma      akkoma
      superuser_map      gotosocial  gotosocial
      superuser_map      keycloak    keycloak
      superuser_map      mastodon    mastodon
    '';
    authentication = lib.mkOverride 10 ''
      #type database  DBuser    auth-method optional_ident_map
      local sameuser  all       peer        map=superuser_map
      local all       postgres  peer        map=superuser_map
    '';
  };
}
