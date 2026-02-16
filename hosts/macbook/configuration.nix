{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  # NEW: Set primary user for system defaults
  system.primaryUser = "alongo";

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    jq
    ripgrep
    fd
    tree
    tmux
    sops
    age
  ];

  programs.fish.enable = true;

  users.users.alongo = {
    name = "alongo";
    home = "/Users/alongo";
    shell = pkgs.fish;
  };

  system = {
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        orientation = "bottom";
      };
      
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
      };
      
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleInterfaceStyle = "Dark";
      };
    };
    
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  system.stateVersion = 6;
  system.configurationRevision = null;
}
