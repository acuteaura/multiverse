{
  config,
  pkgs,
  ...
}: let
  backupDir = "/var/backup/gotosocial";
in {
  services.restic.backups.gotosocial = {
    repositoryFile = "/etc/restic/repository";
    initialize = true;
    passwordFile = "/etc/restic/password";

    paths = [
      backupDir
      config.services.gotosocial.settings.storage-local-base-path
    ];

    backupPrepareCommand = ''
      mkdir -p ${backupDir}
      chown gotosocial:gotosocial ${backupDir}

      # dump the gotosocial postgresql database
      ${pkgs.sudo}/bin/sudo -u gotosocial \
        ${config.services.postgresql.package}/bin/pg_dump \
        -Fc -f ${backupDir}/gotosocial.pgdump \
        gotosocial

      # export federation-critical data (keys, follows, blocks) as a safety net
      gotosocial-admin export --path ${backupDir}/gts-export.json
    '';

    backupCleanupCommand = ''
      rm -rf ${backupDir}
    '';

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };

  systemd.services.restic-backups-gotosocial = {
    unitConfig = {
      ConditionPathExists = [
        config.services.restic.backups.gotosocial.repositoryFile
        config.services.restic.backups.gotosocial.passwordFile
      ];
    };
  };
}
