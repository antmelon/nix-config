{ pkgs, ... }:

{
  # Podman as a rootful daemon-less docker substitute; CLI alias provides `docker`.
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      # aardvark-dns would bind 10.88.0.1:53 and collide with AdGuard on this host.
      # Inter-container DNS isn't needed — services are reached via 127.0.0.1 ports.
      defaultNetwork.settings.dns_enabled = false;
    };
    oci-containers.backend = "podman";
  };

  # Lets `alongo` evaluate flakes without sudo prompts during remote dev.
  nix.settings.trusted-users = [ "root" "alongo" ];

  # Dev services bind to localhost only; reach them via tailscale SSH (-L forwards
  # or by running tools while SSH'd in). Credentials are intentionally trivial.
  virtualisation.oci-containers.containers = {
    dev-postgres = {
      image = "postgres:16";
      environment = {
        POSTGRES_USER = "dev";
        POSTGRES_PASSWORD = "dev";
        POSTGRES_DB = "postgres";
      };
      volumes = [ "dev-postgres:/var/lib/postgresql/data" ];
      ports = [ "127.0.0.1:5432:5432" ];
    };

    dev-redis = {
      image = "redis:7-alpine";
      volumes = [ "dev-redis:/data" ];
      ports = [ "127.0.0.1:6379:6379" ];
    };

    dev-mailpit = {
      image = "axllent/mailpit:latest";
      ports = [
        "127.0.0.1:1025:1025"
        "127.0.0.1:8025:8025"
      ];
    };
  };

  # Expose Mailpit's web UI as svc:mail on the tailnet (https://mail/).
  # SMTP (port 1025) stays localhost-only — apps under dev send via SSH tunnel.
  systemd.services.tailscale-serve-mail = {
    description = "Advertise Mailpit as Tailscale Service svc:mail";
    after = [ "tailscaled.service" "network-online.target" "podman-dev-mailpit.service" ];
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
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:mail --bg --https=443 http://127.0.0.1:8025
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:mail advertise svc:mail
    '';
  };
}
