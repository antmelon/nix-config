{ pkgs, ... }:

# File share hub. Files live only here, in /home/alongo/files:
#   - NFS export, mounted by balthasar at ~/melchior; balthasar's ~/Music is a
#     symlink to ~/melchior/Music for omatunes (music_dir = ~/Music).
#   - File Browser web UI (svc:files) for uploading/organising from anywhere
#     on the tailnet.
# Under /home, so the nightly restic backup (./backups.nix) covers it.
let
  filesDir = "/home/alongo/files";
  balthasarIp = "100.111.138.93";  # tailscale IP (stable per node)
  fbPort = 8090;
in
{
  # alongo is uid 1001 here but uid 1000 on balthasar, and sec=sys NFS
  # matches owners by number. all_squash + anonuid maps every request from
  # balthasar to alongo, so omatunes can write tags without uid juggling.
  # No firewall rule needed: tailscale0 is trusted wholesale.
  services.nfs.server = {
    enable = true;
    exports = ''
      ${filesDir} ${balthasarIp}(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=100)
    '';
  };

  # Runs as alongo so uploads land owned by alongo, same as NFS writes.
  # Logins are File Browser's own users; on first start it creates `admin`
  # with a random password printed once in `journalctl -u filebrowser`.
  services.filebrowser = {
    enable = true;
    user = "alongo";
    group = "users";
    settings = {
      address = "127.0.0.1";
      port = fbPort;
      root = filesDir;
    };
  };

  # Top-level folders. Add more freely (in File Browser or here); these are
  # just guaranteed to exist. Music is omatunes' library.
  systemd.tmpfiles.settings.files = {
    "${filesDir}/Music".d = { user = "alongo"; group = "users"; mode = "0755"; };
    "${filesDir}/Documents".d = { user = "alongo"; group = "users"; mode = "0755"; };
  };

  # Expose File Browser as svc:files on the tailnet (https://files/).
  systemd.services.tailscale-serve-files = {
    description = "Advertise File Browser as Tailscale Service svc:files";
    after = [ "tailscaled.service" "network-online.target" "filebrowser.service" ];
    wants = [ "network-online.target" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for _ in $(seq 1 30); do
        ${pkgs.tailscale}/bin/tailscale status --self=true --peers=false >/dev/null 2>&1 && break
        sleep 1
      done
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:files --bg --https=443 http://127.0.0.1:${toString fbPort}
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:files advertise svc:files
    '';
  };
}
