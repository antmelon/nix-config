{ config, pkgs, ... }:

{
  # Import common
  # NEW: Set primary user for system defaults
  system.primaryUser = "alongo";

  environment.systemPackages = with pkgs; [
   pkgs.yt-dlp 
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

  services.tailscale.enable = true;

  # Stay reachable on the tailnet when plugged in (battery sleep behavior
  # is left at its default). Display sleep is untouched.
  system.activationScripts.pmsetAC.text = ''
    /usr/bin/pmset -c sleep 0
  '';

  # nix-darwin's tailscale module only starts tailscaled; it has no
  # equivalent of NixOS's `extraSetFlags`, so apply `--ssh` via a launchd
  # daemon that runs once at load and exits.
  launchd.daemons.tailscale-set-ssh = {
    serviceConfig = {
      Label = "com.user.tailscale-set-ssh";
      RunAtLoad = true;
      KeepAlive = false;
      ProgramArguments = [
        "${pkgs.writeShellScript "tailscale-set-ssh" ''
          for _ in $(seq 1 30); do
            ${pkgs.tailscale}/bin/tailscale status --self=true --peers=false >/dev/null 2>&1 && break
            sleep 1
          done
          ${pkgs.tailscale}/bin/tailscale set --ssh
        ''}"
      ];
    };
  };

  system.stateVersion = 6;
  system.configurationRevision = null;
}
