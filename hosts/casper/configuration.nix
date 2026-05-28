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

  # Tailscale is installed as the GUI app via Homebrew. The bundled
  # system extension provides a real utun interface, which is required
  # for tailscaled to push DNS settings to macOS (MagicDNS, override-
  # local-DNS, etc.). nix-darwin's services.tailscale runs tailscaled
  # in userspace-networking mode, which deliberately does not touch
  # system DNS.
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    casks = [ "tailscale-app" ];
  };

  # Stay reachable on the tailnet when plugged in (battery sleep behavior
  # is left at its default). Display sleep is untouched.
  system.activationScripts.pmsetAC.text = ''
    /usr/bin/pmset -c sleep 0
  '';

  # Enable macOS Remote Login (OpenSSH). The Tailscale GUI app's
  # embedded daemon is sandboxed and cannot run an SSH server, so we
  # use system sshd and reach it over the tailnet via MagicDNS
  # (ssh alongo@casper).
  system.activationScripts.remoteLogin.text = ''
    /usr/sbin/systemsetup -setremotelogin on > /dev/null
  '';

  system.stateVersion = 6;
  system.configurationRevision = null;
}
