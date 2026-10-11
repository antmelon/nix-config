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
  #
  # Everything else is GUI apps, plus the tools that don't fit Nix well (rbenv
  # builds rubies against Homebrew's openssl/libyaml; cocoapods wants a
  # Homebrew-style ruby). Casks already in /Applications from the old Intel
  # Homebrew need `brew install --cask --adopt <name>` once, or bundle stops
  # with "already an App".
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    brews = [
      "rbenv"
      "cocoapods"
    ];
    casks = [
      "tailscale-app"
      "alacritty"
      "amethyst"
      "bitwarden"
      "discord"
      "hiddenbar"
      "mailspring"
      "spotify"
      "steam"
      "the-unarchiver"
      # Not warp: its cask checksum lags Warp's releases, and a failed
      # download fails the whole activation. Warp updates itself anyway.
    ];
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
