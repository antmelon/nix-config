{ ... }:

{
  # Podman as a rootful daemon-less docker substitute; CLI alias provides `docker`.
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
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
}
