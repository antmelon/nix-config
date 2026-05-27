{ pkgs, ... }:

{
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 8080;
      };
      theme = {
        background-color = "240 8 9";
        primary-color = "43 50 70";
        contrast-multiplier = 1.1;
      };
      pages = [{
        name = "Home";
        columns = [
          {
            size = "small";
            widgets = [
              { type = "calendar"; }
              {
                type = "weather";
                location = "New York City, United States";
                units = "imperial";
              }
            ];
          }
          {
            size = "full";
            widgets = [
              {
                type = "releases";
                repositories = [
                  "NixOS/nixpkgs"
                  "nix-community/home-manager"
                  "glanceapp/glance"
                ];
              }
              {
                type = "rss";
                title = "NixOS News";
                feeds = [
                  { url = "https://nixos.org/blog/announcements-rss.xml"; }
                  { url = "https://discourse.nixos.org/c/announcements/8.rss"; }
                ];
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "server-stats";
                servers = [{
                  type = "local";
                  name = "melchior";
                }];
              }
              {
                type = "bookmarks";
                groups = [{
                  title = "Quick Links";
                  links = [
                    { title = "GitHub"; url = "https://github.com"; }
                    { title = "NixOS Search"; url = "https://search.nixos.org"; }
                    { title = "Foundry VTT"; url = "http://melchior:30000"; }
                    { title = "Backblaze (backups)"; url = "https://secure.backblaze.com/b2_buckets.htm"; }
                  ];
                }];
              }
            ];
          }
        ];
      }];
    };
  };

  # Expose glance on the tailnet as https://glances/ via a Tailscale Service.
  # No nixpkgs module covers `tailscale serve` yet, so we re-apply the CLI
  # config on every boot. Calls are idempotent.
  systemd.services.tailscale-serve-glance = {
    description = "Advertise glance as Tailscale Service svc:glances";
    after = [ "tailscaled.service" "network-online.target" ];
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
      ${pkgs.tailscale}/bin/tailscale set --advertise-services=svc:glances
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:glances --bg --https=443 http://127.0.0.1:8080
    '';
  };
}
