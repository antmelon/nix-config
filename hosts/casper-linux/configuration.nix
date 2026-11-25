{ lib, pkgs, ... }:

# casper's Omarchy side: Asahi on the same M1, aarch64-linux. Both it and
# balthasar are Arch underneath, so this is balthasar's setup: home-manager
# only, Omarchy owns the system layer. The macOS side stays
# darwinConfigurations.casper. Like balthasar, no dev-toolchain.nix: Nix's gcc
# on Arch breaks binaries at runtime, so Arch's gcc + rustup are used.
{
  imports = [
    ../../home/alongo/base.nix
    ../../home/alongo/linux.nix
    ../../home/alongo/programs/syncthing.nix
  ];

  programs.home-manager.enable = true;

  # No system nix module here (as on balthasar), so HM writes nix.conf.
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # The shared aliases assume casper is macOS. On this side, updating or
  # editing casper means this config.
  programs.fish.shellAliases = {
    updatecasper = lib.mkForce "home-manager switch --flake ~/.config/nix-config#casper-linux";
    editcasper   = lib.mkForce "nvim ~/.config/nix-config/hosts/casper-linux/configuration.nix";
  };
}
