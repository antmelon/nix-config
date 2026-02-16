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
      starship  # Add starship so it's managed by nix
    ];
    
    # Environment variables
    sessionVariables = {
      GOPATH = "$HOME/go";
      GOROOT = "/usr/local/go";
      GOBIN = "$HOME/go/bin";
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
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      core = {
        editor = "vim";
      };
    };
  };

  # Fish configuration - will merge with your existing config
  programs.fish = {
    enable = true;
    
    shellInit = ''
      # Nix daemon (you already have this in config.fish, but keeping it here)
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
      
      # Git
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      
      # Nix/Darwin
      update = "darwin-rebuild switch --flake ~/.config/nixos-config#MacBook-Pro-4";
      
      # Better commands
      cat = "bat";
      ls = "eza";
      
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
