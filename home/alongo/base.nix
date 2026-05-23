{ config, pkgs, ... }:

{
  imports = [
    ./programs/nvim.nix
    ./programs/tmux.nix
    ./programs/fish-extras.nix
  ];

  home = {
    stateVersion = "24.11";

    packages = with pkgs; [
      # Network
      curl
      wget

      # System monitoring
      htop

      # Text processing
      jq
      ripgrep
      fd
      tree

      # Terminal
      bat
      eza
      fzf

      # Secrets
      sops
      age

      # Editor
      neovim

      # Dev toolchain
      gcc
      cmake
      ninja
      rustc
      cargo
      python3
    ];

    sessionVariables = {
      GOPATH = "$HOME/go";
      GOROOT = "/usr/local/go";
      GOBIN  = "$HOME/go/bin";
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/personal.txt";
      EDITOR = "nvim";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "/usr/local/go/bin"
      "$HOME/.cabal/bin"
      "$HOME/.ghcup/bin"
      "$HOME/.codeium/windsurf/bin"
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
    ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Ant";
        email = "alongo0925@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase        = true;
      core.editor        = "nvim";
    };
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      starship init fish | source
    '';

    interactiveShellInit = ''
      set fish_greeting
    '';

    shellAliases = {
      # Navigation
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";

      # Editor
      vim = "nvim";
      vi  = "nvim";
      v   = "nvim";

      # Git
      gs  = "git status";
      gp  = "git push";
      gl  = "git pull";
      gd  = "git diff";
      ga  = "git add";
      gc  = "git commit";
      gco = "git checkout";

      # System updates
      updatecasper    = "sudo darwin-rebuild switch --flake ~/.config/nix-config#casper";
      updatebalthasar = "home-manager switch --flake ~/.config/nix-config#balthasar";
      updatemelchior  = "nixos-rebuild switch --flake ~/.config/nix-config#melchior --target-host melchior --use-remote-sudo";

      # Edit configs
      editcasper    = "nvim ~/.config/nix-config/hosts/casper/configuration.nix";
      editmelchior  = "nvim ~/.config/nix-config/hosts/melchior/configuration.nix";
      editbalthasar = "nvim ~/.config/nix-config/hosts/balthasar/configuration.nix";
      editcommon    = "nvim ~/.config/nix-config/modules/common.nix";
      edithome      = "nvim ~/.config/nix-config/home/alongo/base.nix";
      editflake     = "nvim ~/.config/nix-config/flake.nix";

      # Edit secrets
      secretcasper    = "sops ~/.config/nix-config/secrets/casper.yaml";
      secretmelchior  = "sops ~/.config/nix-config/secrets/melchior.yaml";
      secretbalthasar = "sops ~/.config/nix-config/secrets/balthasar.yaml";
      secretshared    = "sops ~/.config/nix-config/secrets/shared.yaml";

      # Navigation
      cdnix = "cd ~/.config/nix-config";

      # Better defaults
      cat  = "bat";
      ls   = "eza";
      grep = "rg";
      find = "fd";
      cls  = "clear";
    };
  };

  programs.starship.enable = true;
}
