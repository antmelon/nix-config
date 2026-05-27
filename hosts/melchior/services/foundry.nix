{ inputs, pkgs, ... }:

let
  publicHost = "melchior.taile2fc00.ts.net";
in
{
  services.foundryvtt = {
    enable = true;
    hostName = publicHost;
    port = 30000;
    proxyPort = 443;
    proxySSL = true;
    routePrefix = "foundry";
    upnp = false;
    minifyStaticFiles = true;
    package = inputs.foundryvtt.packages.${pkgs.system}.foundryvtt_latest;
  };

  # Expose Foundry to the public internet via Tailscale Funnel so friends
  # can join without being on the tailnet. Requires the `funnel` node
  # attribute granted to melchior in the tailnet ACL — without it the
  # CLI refuses. Funnel and Services configs are independent, so this
  # coexists with svc:glances.
  systemd.services.tailscale-funnel-foundry = {
    description = "Publish Foundry VTT via Tailscale Funnel";
    after = [ "tailscaled.service" "network-online.target" "foundryvtt.service" ];
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
      ${pkgs.tailscale}/bin/tailscale funnel --bg --yes --https=443 --set-path=/foundry http://127.0.0.1:30000/foundry
    '';
  };
}
