{ pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      DOMAIN = "https://vault.taile2fc00.ts.net";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      # Tailnet-only access via svc:vault, so signups are reasonably safe.
      # Flip to false after registering the account if you want belt-and-suspenders.
      SIGNUPS_ALLOWED = true;
      WEB_VAULT_ENABLED = true;
    };
  };

  # Expose Vaultwarden as svc:vault on the tailnet (https://vault/).
  # No public funnel — password data should never be on the open internet.
  systemd.services.tailscale-serve-vault = {
    description = "Advertise Vaultwarden as Tailscale Service svc:vault";
    after = [ "tailscaled.service" "network-online.target" "vaultwarden.service" ];
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
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:vault --bg --https=443 http://127.0.0.1:8222
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:vault advertise svc:vault
    '';
  };
}
