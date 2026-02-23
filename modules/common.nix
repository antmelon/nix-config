# Common configuration shared across all systems
{ config, pkgs, lib, ... }:

{
  # Common packages for ALL systems (Mac, Linux, homeserver, etc.)
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    git
    curl
    wget
    
    # System monitoring
    htop
    
    # Text processing
    jq
    ripgrep
    fd
    
    # Terminal utilities
    tree
    tmux
    
    # Better commands
    bat
    eza
    fzf
    
    # Secrets management
    sops
    age
    
    # Development toolchain
    gcc
    cmake
    ninja
    
    # Rust
    rustc
    cargo
    
    # Python
    python3
    python3Packages.pip
  ];

  # Enable nix flakes everywhere
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  
  # Optimize nix store (use the correct option for darwin)
  nix.optimise.automatic = true;
}
