{ config, pkgs, ... }:

{
  imports = [
    ../../home/alongo/base.nix
    ../../home/alongo/linux.nix
    ../../home/alongo/programs/syncthing.nix
  ];

  programs.home-manager.enable = true;

  # Music library from melchior, for omatunes (music_dir = ~/Music).
  # Folder id must match the hub's folders.music.
  services.syncthing.settings.folders.music = {
    path = "${config.home.homeDirectory}/Music";
    label = "Music";
    devices = [ "melchior" ];
  };

  # casper/melchior get this from modules/common.nix at the system level;
  # balthasar is home-manager only, so write ~/.config/nix/nix.conf instead.
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
