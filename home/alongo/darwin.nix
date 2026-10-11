{ pkgs, ... }:

{
  home = {
    username     = "alongo";
    homeDirectory = "/Users/alongo";

    # casper-only CLI tools, moved here from the old Intel Homebrew in
    # /usr/local. rbenv and cocoapods stay in Homebrew (hosts/casper).
    packages = with pkgs; [
      nodejs
      gleam
      beamPackages.erlang   # gleam's BEAM runtime; Homebrew's gleam pulled it in
      beamPackages.rebar3
      pass
      gnupg
      exercism
      pipenv
    ];
  };

  # Homebrew's own bin dirs aren't on PATH by default (nix-darwin doesn't add
  # them). Append, not prepend, so Nix packages win over anything Homebrew
  # links as a dependency.
  programs.fish.shellInit = ''
    fish_add_path --global --append /opt/homebrew/bin /opt/homebrew/sbin
  '';
}
