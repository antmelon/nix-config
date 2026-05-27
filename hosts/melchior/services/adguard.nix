{ pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    # mutableSettings = true lets you tweak filters/clients in the web UI
    # without re-deploying. The block below seeds the initial settings.
    mutableSettings = true;
    host = "127.0.0.1";
    port = 3000;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [
          "https://1.1.1.1/dns-query"
          "https://1.0.0.1/dns-query"
        ];
        bootstrap_dns = [ "1.1.1.1" "1.0.0.1" ];
      };
      filters = [
        {
          enabled = true;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          id = 1;
        }
        {
          enabled = true;
          name = "AdAway Default Blocklist";
          url = "https://adaway.org/hosts.txt";
          id = 2;
        }
      ];
    };
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
