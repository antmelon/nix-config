{ config, pkgs, ... }:

{
  home = {
    username = "alongo";
    homeDirectory = "/Users/alongo";
    stateVersion = "24.11";

    packages = with pkgs; [
      bat
      eza
      fzf
      starship
      neovim
    ];

    # Environment variables
    sessionVariables = {
      GOPATH = "$HOME/go";
      GOROOT = "/usr/local/go";
      GOBIN = "$HOME/go/bin";
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
        name = "Ant";
        email = "your@email.com";  # CHANGE THIS
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "vim";
    };
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      # Nix daemon
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end

      # Starship prompt
      starship init fish | source
    '';

    interactiveShellInit = ''
      set fish_greeting
    '';

    loginShellInit = ''
      # Start X at login (from your old config)
      if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
      end
    '';

    shellAliases = {
      # Navigation
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";

      # use nvim
      vim = "nvim";
      vi = "nvim";
      v = "nvim";

      # Git shortcuts
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";

      # System updates
      updatecasper = "sudo darwin-rebuild switch --flake ~/.config/nix-config#casper";
      updatemelchior = "nixos-rebuild switch --flake ~/.config/nix-config#melchior --target-host melchior --use-remote-sudo";
      updatebalthasar = "nixos-rebuild switch --flake ~/.config/nix-config#balthasar --target-host balthasar --use-remote-sudo";

      # Edit configurations
      editcasper = "vim ~/.config/nix-config/hosts/casper/configuration.nix";
      editmelchior = "vim ~/.config/nix-config/hosts/melchior/configuration.nix";
      editbalthasar = "vim ~/.config/nix-config/hosts/balthasar/configuration.nix";
      editcommon = "vim ~/.config/nix-config/modules/common.nix";
      edithome = "vim ~/.config/nix-config/home/alongo/default.nix";
      editflake = "vim ~/.config/nix-config/flake.nix";

      # Edit secrets
      secretcasper = "sops ~/.config/nix-config/secrets/casper.yaml";
      secretmelchior = "sops ~/.config/nix-config/secrets/melchior.yaml";
      secretbalthasar = "sops ~/.config/nix-config/secrets/balthasar.yaml";
      secretshared = "sops ~/.config/nix-config/secrets/shared.yaml";

      # Quick navigation to config
      cdnix = "cd ~/.config/nix-config";

      # Better commands
      cat = "bat";
      ls = "eza";
      grep = "rg";
      find = "fd";
    };
  };

  programs.vim = {
    enable = true;
    settings = {
      number = true;
      relativenumber = true;
    };
  };

  programs.starship = {
    enable = true;
    # You can add starship config here if you want
    # settings = {
    #   # your starship.toml settings
    # };
  };
}
