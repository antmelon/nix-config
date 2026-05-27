{ inputs, pkgs, ... }:

{
  services.foundryvtt = {
    enable = true;
    hostName = "melchior";
    port = 30000;
    upnp = false;
    minifyStaticFiles = true;
    package = inputs.foundryvtt.packages.${pkgs.system}.foundryvtt_latest;
  };
}
