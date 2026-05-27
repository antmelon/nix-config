{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services/glance.nix
    ./services/backups.nix
    ../../modules/common.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "melchior";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York"; # TODO: confirm timezone

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.alongo = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" ];
    shell        = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPcpj/4y4RM7WRHD/8RXgJASHgYTZ3NyAvg0aNdkugg alongo0925@gmail.com"
    ];
  };

  security.sudo.extraRules = [{
    users = [ "alongo" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  programs.fish.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  home-manager = {
    useGlobalPkgs   = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.alongo = { imports = [ ../../home/alongo/base.nix ../../home/alongo/linux.nix ]; };
  };

  # Per-service modules live in ./services/ — add new ones to imports above.

  system.stateVersion = "24.11";
}
