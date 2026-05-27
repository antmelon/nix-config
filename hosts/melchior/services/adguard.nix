{ pkgs, ... }:

{
  # settings = null is intentional: with declarative settings, the NixOS
  # module writes the yaml on first boot and AdGuard skips its install
  # wizard. Leaving settings unset lets the wizard run, after which the
  # yaml persists across rebuilds (mutableSettings defaults to true).
  services.adguardhome = {
    enable = true;
  };

  # Open DNS on the LAN. Tailscale-side traffic is already trusted via
  # the `trustedInterfaces = [ "tailscale0" ]` rule in configuration.nix.
  # The web UI is bound to 127.0.0.1 and exposed only via svc:adguard.
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  systemd.services.tailscale-serve-adguard = {
    description = "Advertise AdGuard Home admin UI as Tailscale Service svc:adguard";
    after = [ "tailscaled.service" "network-online.target" "adguardhome.service" ];
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
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:adguard --bg --https=443 http://127.0.0.1:3000
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:adguard advertise svc:adguard
    '';
  };
}
