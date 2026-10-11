{ config, pkgs, ... }:

let
  # BruLogger's production Supabase project ("Coffee App"). The free plan has no
  # backups, and Supabase's own (Pro) backups don't include Storage files anyway.
  projectRef = "gnrjhylsbfzqfeenoxwa";

  # Tables whose rows are live sign-in state, not data: sessions and refresh
  # tokens would let anyone holding a leaked dump sign in as the user. After a
  # restore people just sign in again. Audit log rows are IPs and noise.
  skipData = [
    "auth.sessions"
    "auth.refresh_tokens"
    "auth.one_time_tokens"
    "auth.flow_state"
    "auth.mfa_challenges"
    "auth.mfa_amr_claims" # points at sessions, so it can't be restored without them
    "auth.audit_log_entries"
  ];

  backup = pkgs.writeShellApplication {
    name = "brulogger-backup";
    # pg_dump must be at least the server's major version (17 today), so use the
    # newest one: an older client refuses newer servers after a Supabase upgrade.
    runtimeInputs = with pkgs; [ postgresql_18 rclone coreutils findutils gnugrep ];
    text = ''
      cd "$STATE_DIRECTORY"
      mkdir -p db photos
      stamp=$(date -u +%Y-%m-%dT%H%MZ)

      # Database: users (auth), brews (public) and bucket/object records
      # (storage), schema and data, in pg_dump's compressed custom format.
      pg_dump --format=custom --schema=public --schema=auth --schema=storage \
        ${pkgs.lib.concatMapStringsSep " " (t: "--exclude-table-data=${t}") skipData} \
        --file="db/.brulogger-$stamp.dump.tmp"
      # A dump that doesn't list the brews data isn't a backup
      pg_restore --list "db/.brulogger-$stamp.dump.tmp" | grep -q ' TABLE DATA public brews '
      mv "db/.brulogger-$stamp.dump.tmp" "db/brulogger-$stamp.dump"

      # Photos: mirror the bucket. Deletions are mirrored too; restic's snapshots
      # of this directory keep older versions.
      rclone sync supabase:brew-photos photos --fast-list --checksum

      # Two weeks of dumps here; restic keeps months of them off-site
      find db -name 'brulogger-*.dump' -mtime +14 -delete

      brews=$(psql --no-psqlrc --tuples-only --no-align --command='select count(*) from public.brews')
      echo "$stamp brews=$brews photos=$(find photos -type f | wc -l) dump=$(du -h "db/brulogger-$stamp.dump" | cut -f1)" \
        | tee -a log.txt
    '';
  };

  # Telegram message through the Hermes bot, to the same DM it delivers cron
  # results to (hermes.nix: home_channel).
  notifyFailure = pkgs.writeShellScript "brulogger-backup-failed" ''
    ${pkgs.curl}/bin/curl -sS --max-time 20 \
      "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
      --data-urlencode chat_id=1049244523 \
      --data-urlencode text="BruLogger backup failed on melchior. journalctl -u brulogger-backup"
  '';
in
{
  # Nightly backup of BruLogger (Supabase) into /var/lib/brulogger-backup, which
  # the restic job in backups.nix then copies off-site, encrypted, to B2.
  # Restore steps are in the BruLogger README ("Backups").

  # KEY=VALUE env file:
  #   PGPASSWORD  the password of brulogger_backup, a read-only role (login,
  #     bypassrls, pg_read_all_data) created by hand in Supabase's SQL editor.
  #     bypassrls because brews and storage.objects have row-level security,
  #     and pg_dump refuses to dump a table it can only partly see.
  #   RCLONE_CONFIG_SUPABASE_ACCESS_KEY_ID, RCLONE_CONFIG_SUPABASE_SECRET_ACCESS_KEY
  #     a Storage S3 access key (Supabase dashboard: Project Settings > Storage)
  sops.secrets."brulogger-backup/env" = { };

  systemd.services.brulogger-backup = {
    description = "Back up the BruLogger database and photos";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    onFailure = [ "brulogger-backup-failed.service" ];
    environment = {
      # Supabase's session pooler (pg_dump needs a session, not transaction, pooler)
      PGHOST = "aws-1-us-east-2.pooler.supabase.com";
      PGPORT = "5432";
      PGDATABASE = "postgres";
      PGUSER = "brulogger_backup.${projectRef}"; # <role>.<project> on the pooler
      PGSSLMODE = "require";
      # rclone remote "supabase:" from environment variables only; no config file
      RCLONE_CONFIG = "/dev/null";
      RCLONE_CONFIG_SUPABASE_TYPE = "s3";
      RCLONE_CONFIG_SUPABASE_PROVIDER = "Other";
      RCLONE_CONFIG_SUPABASE_ENDPOINT = "https://${projectRef}.supabase.co/storage/v1/s3";
      RCLONE_CONFIG_SUPABASE_REGION = "us-east-2";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${backup}/bin/brulogger-backup";
      EnvironmentFile = config.sops.secrets."brulogger-backup/env".path;
      DynamicUser = true;
      StateDirectory = "brulogger-backup";
      StateDirectoryMode = "0700";
      UMask = "0077";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  systemd.timers.brulogger-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Before restic's daily run (backups.nix: OnCalendar daily, up to 1h late),
      # so each night's snapshot carries that night's dump
      OnCalendar = "*-*-* 23:15:00";
      Persistent = true;
    };
  };

  systemd.services.brulogger-backup-failed = {
    description = "Tell the user the BruLogger backup failed";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = notifyFailure;
      # TELEGRAM_BOT_TOKEN
      EnvironmentFile = config.sops.secrets."hermes/env".path;
      DynamicUser = true;
    };
  };
}
