{lib, ...}: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["akkoma"];
    ensureUsers = [
      {
        name = "akkoma";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres
      superuser_map      akkoma    akkoma
    '';
    authentication = lib.mkOverride 10 ''
      #type database  DBuser  auth-method optional_ident_map
      local sameuser  all     peer        map=superuser_map
    '';
  };
}
