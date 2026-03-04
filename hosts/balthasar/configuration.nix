{ config, pkgs, lib, ... }:

{
  home = {
    username = "alongo";  # Change to your Arch username
    homeDirectory = lib.mkForce "/home/alongo";  # Change to match
    stateVersion = "24.11";

    # Packages you want from Nix
    packages = with pkgs; [
      # Already in common.nix via flake, but you can add more here
    ];

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/personal.txt";
    };
  };

  programs.home-manager.enable = true;

  # Import your shared home config
  imports = [
    ../../home/alongo/default.nix
  ];

  # Override any settings specific to Linux/balthasar
  programs.fish = {
    # Most settings come from home/alongo/default.nix
    # Override shell aliases for balthasar-specific paths
    shellAliases = {
      # Navigation
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";

      # Git shortcuts
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";

      # Note: No updatebalthasar since we're not managing the system
      # Just home-manager
      updatehome = "home-manager switch --flake ~/.config/nix-config#balthasar";

      # Edit configurations
      editbalthasar = "vim ~/.config/nix-config/hosts/balthasar/configuration.nix";
      editcommon = "vim ~/.config/nix-config/modules/common.nix";
      edithome = "vim ~/.config/nix-config/home/alongo/default.nix";

      # Edit secrets
      secretbalthasar = "sops ~/.config/nix-config/secrets/balthasar.yaml";
      secretshared = "sops ~/.config/nix-config/secrets/shared.yaml";

      # Quick navigation
      cdnix = "cd ~/.config/nix-config";

      # Better commands
      cat = "bat";
      ls = "eza";
      grep = "rg";
      find = "fd";
    };
  };
}
