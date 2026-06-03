{ config, lib, pkgs, ... }:

# Syncthing hub. melchior is the always-on node, so it runs as a NixOS system
# service (starts at boot with no login session, unlike a home-manager user
# service). It shares ~/sync/tasks with every client listed in the peer
# registry; tuxedo's todo.txt lives in that folder.
#
# Device IDs come from ../../../modules/syncthing-peers.nix — see that file for
# the one-time bootstrap procedure. Peers whose id is still "" are filtered out.
let
  peers = import ../../../modules/syncthing-peers.nix;
  selfName = "melchior";
  knownPeers = lib.filterAttrs (name: p: name != selfName && p.id != "") peers;
in
{
  services.syncthing = {
    enable = true;
    user = "alongo";
    group = "users";
    # Syncthing's own config + database. Kept under alongo's home: the service
    # runs as alongo (so it can read/write ~/sync/tasks directly), and the
    # module only auto-creates /var/lib/syncthing for its default `syncthing`
    # user — overriding the user leaves that dir unprovisioned, so syncthing
    # fails with "mkdir /var/lib/syncthing: permission denied". alongo's home
    # already exists and is writable, so the daemon creates its dirs there.
    dataDir = "/home/alongo/.local/share/syncthing";
    # Fully declarative: anything added via the GUI is reverted on restart.
    overrideDevices = true;
    overrideFolders = true;
    # GUI stays on loopback. Reach it when needed with an SSH tunnel:
    #   ssh -L 8384:127.0.0.1:8384 melchior  ->  http://127.0.0.1:8384
    guiAddress = "127.0.0.1:8384";

    settings = {
      options = {
        urAccepted = -1;             # decline anonymous usage reporting
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;          # tailnet handles reachability
      };

      devices = lib.mapAttrs (_: p: {
        inherit (p) id addresses;
      }) knownPeers;

      folders.tasks = {
        path = "/home/alongo/sync/tasks";
        label = "Tasks";
        devices = lib.attrNames knownPeers;
      };
    };
  };

  # Sync transport (22000/tcp+udp) and discovery (21027/udp) need no firewall
  # rules: melchior already trusts tailscale0 wholesale (see configuration.nix),
  # and we don't expose Syncthing to the LAN/WAN.
}
