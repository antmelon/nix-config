{ config, lib, pkgs, ... }:

# Syncthing client (casper, balthasar). Runs as a home-manager user service —
# systemd --user on Linux, a launchd agent on macOS. Hub-and-spoke: each client
# only peers with the always-on melchior hub, which fans changes out to the
# others. Folder id "tasks" must match the hub's folder, so sharing is
# automatic and needs no GUI device-acceptance.
#
# Imported explicitly by casper (flake.nix) and balthasar
# (hosts/balthasar/configuration.nix) — NOT from base.nix/linux.nix, so the
# melchior host (which runs the system-level hub) never starts a second
# user-level instance.
let
  peers = import ../../../modules/syncthing-peers.nix;
  hubKnown = peers.melchior.id != "";
in
{
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };

      # Until melchior's ID is filled in, this is an empty local folder.
      devices = lib.optionalAttrs hubKnown {
        melchior = { inherit (peers.melchior) id addresses; };
      };

      folders.tasks = {
        path = "${config.home.homeDirectory}/sync/tasks";
        label = "Tasks";
        devices = lib.optionals hubKnown [ "melchior" ];
      };
    };
  };
}
