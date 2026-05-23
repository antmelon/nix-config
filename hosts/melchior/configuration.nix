{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "melchior";

  # TODO: configure boot loader after partitioning
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # TODO: configure filesystems after partitioning
  # fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York"; # TODO: confirm timezone

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.alongo = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" ];
    shell        = pkgs.fish;
  };

  programs.fish.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # TODO: open ports as needed
  networking.firewall.enable = true;

  home-manager = {
    useGlobalPkgs   = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.alongo = { imports = [ ../../home/alongo/base.nix ../../home/alongo/linux.nix ]; };
  };

  # TODO: add melchior services here (Foundry VTT, Glance, Tailscale, etc.)

  system.stateVersion = "24.11";
}
