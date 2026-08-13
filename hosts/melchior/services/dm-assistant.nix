{ inputs, pkgs, ... }:

let
  # The built static site (Vite dist/) from the dm-assistant flake input.
  site = inputs.dm-assistant.packages.${pkgs.stdenv.hostPlatform.system}.default;
  port = 8085;
in
{
  # Serve the SPA from a read-only Nix store path on localhost. No nginx — this
  # matches the "localhost HTTP port + tailscale serve" pattern used by the
  # other services here.
  services.static-web-server = {
    enable = true;
    listen = "127.0.0.1:${toString port}";
    root = site;
    configuration.general = {
      log-level = "error";
      # Client-side routing: serve index.html for unknown GET paths so deep
      # links (e.g. /campaigns/:id/sessions/:id) survive a hard refresh.
      "page-fallback" = "${site}/index.html";
    };
  };

  # Expose on the tailnet as https://dm-assistant.taile2fc00.ts.net via a
  # Tailscale Service (mirrors glance/adguard). No nixpkgs module covers
  # `tailscale serve` yet, so re-apply the CLI config on every boot; the calls
  # are idempotent.
  systemd.services.tailscale-serve-dm-assistant = {
    description = "Advertise DM Assistant as Tailscale Service svc:dm-assistant";
    after = [ "tailscaled.service" "network-online.target" "static-web-server.service" ];
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
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:dm-assistant --bg --https=443 http://127.0.0.1:${toString port}
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:dm-assistant advertise svc:dm-assistant
    '';
  };
}
