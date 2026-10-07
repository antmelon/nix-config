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
      unzip

      # Task manager (todo.txt TUI); tasks live in the Syncthing folder
      tuxedo

      # Secrets
      sops
      age

      # Editor
      neovim

      # Dev toolchain (compilers live in ./dev-toolchain.nix)
      python3
    ];

    sessionVariables = {
      GOPATH = "$HOME/go";
      GOBIN  = "$HOME/go/bin";
      # No GOROOT — Go auto-detects it from the binary. A hardcoded
      # /usr/local/go was stale on balthasar (Arch go lives in /usr/lib/go)
      # and broke every `go build`, incl. AUR packages.
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
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
    ];
  };

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
      # nixos-rebuild from the flake's pinned nixpkgs, so this works from hosts
      # that don't have it installed (balthasar, casper); melchior builds itself.
      updatemelchior  = "nix run --inputs-from ~/.config/nix-config nixpkgs#nixos-rebuild -- switch --flake ~/.config/nix-config#melchior --target-host melchior --build-host melchior --sudo";

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

      # Tasks (todo.txt synced across the Magi via Syncthing)
      t = "tuxedo ~/sync/tasks/todo.txt";

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

  # Starship reads a literal TOML file (home/alongo/programs/starship.toml)
  # rather than programs.starship.settings, so the Nerd Font glyphs in the
  # git-status symbols survive — nix strings / editors strip PUA codepoints.
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./programs/starship.toml;
}
