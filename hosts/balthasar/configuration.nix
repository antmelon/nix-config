{ pkgs, ... }:

{
  imports = [
    ../../home/alongo/base.nix
    ../../home/alongo/linux.nix
  ];

  programs.home-manager.enable = true;
}
