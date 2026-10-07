{ lib, pkgs, ... }:

# Navidrome music server over ~/files/Music (see ./files.nix), exposed as
# svc:music (https://music/). Web player + Subsonic API for phone apps
# (Symfonium/Tempus on Android, Amperfy/play:Sub on iOS).
# Likes/play counts live in Navidrome's own DB, separate from omatunes' tags.
let
  port = 4533;
in
{
  services.navidrome = {
    enable = true;
    # Runs as alongo: File Browser uploads are 0600 alongo, which a separate
    # navidrome user couldn't read. The music dir is still bound read-only.
    user = "alongo";
    group = "users";
    settings = {
      Address = "127.0.0.1";
      Port = port;
      MusicFolder = "/home/alongo/files/Music";
      # File watcher picks up changes immediately; hourly scan as a backstop.
      Scanner.Schedule = "@every 1h";
      EnableInsightsCollector = false;  # decline anonymous usage reporting
    };
  };

  # The module sets ProtectHome=true, which makes /home untraversable for a
  # non-root user, so the MusicFolder bind under /home can't be reached.
  # tmpfs keeps /home hidden but traversable down to the bound folder.
  systemd.services.navidrome.serviceConfig.ProtectHome = lib.mkForce "tmpfs";

  # Expose Navidrome as svc:music on the tailnet (https://music/).
  systemd.services.tailscale-serve-music = {
    description = "Advertise Navidrome as Tailscale Service svc:music";
    after = [ "tailscaled.service" "network-online.target" "navidrome.service" ];
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
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:music --bg --https=443 http://127.0.0.1:${toString port}
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:music advertise svc:music
    '';
  };
}
