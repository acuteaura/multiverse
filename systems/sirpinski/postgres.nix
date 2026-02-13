{lib, ...}: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["akkoma" "gotosocial"];
    ensureUsers = [
      {
        name = "akkoma";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
      {
        name = "gotosocial";
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
    '';
    authentication = lib.mkOverride 10 ''
      #type database  DBuser    auth-method optional_ident_map
      local sameuser  all       peer        map=superuser_map
      local all       postgres  peer        map=superuser_map
    '';
  };
}
