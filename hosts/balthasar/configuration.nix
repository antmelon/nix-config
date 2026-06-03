{ pkgs, ... }:

{
  imports = [
    ../../home/alongo/base.nix
    ../../home/alongo/linux.nix
    ../../home/alongo/programs/syncthing.nix
  ];

  programs.home-manager.enable = true;
}
