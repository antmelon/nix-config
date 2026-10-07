{ pkgs, ... }:

{
  imports = [
    ../../home/alongo/base.nix
    ../../home/alongo/linux.nix
    ../../home/alongo/programs/syncthing.nix
  ];

  programs.home-manager.enable = true;

  # casper/melchior get this from modules/common.nix at the system level;
  # balthasar is home-manager only, so write ~/.config/nix/nix.conf instead.
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
