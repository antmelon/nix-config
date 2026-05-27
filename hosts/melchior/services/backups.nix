{ config, ... }:

{
  sops.defaultSopsFile = ../../../secrets/melchior.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets."restic/password" = { };
  sops.secrets."restic/env" = { };

  services.restic.backups.melchior = {
    paths = [
      "/home"
      "/var/lib"
    ];
    exclude = [
      "/var/lib/systemd"
      "/var/lib/nixos"
      "/home/*/.cache"
    ];
    repository = "b2:melchior-backups:/";
    passwordFile = config.sops.secrets."restic/password".path;
    environmentFile = config.sops.secrets."restic/env".path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
