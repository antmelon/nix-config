# Syncthing peer registry — shared by the melchior hub service and the
# home-manager client module (home/alongo/programs/syncthing.nix).
#
# A device ID is a Syncthing public key. It is NOT a secret — safe to commit.
# Each host generates its own ID the first time syncthing runs there, so this
# file is filled in *after* a one-time bootstrap (see the procedure below).
#
# Empty `id = ""` entries are filtered out by both modules, so the config
# always evaluates and deploys cleanly even while IDs are still missing.
#
# Addresses pin every connection to the tailnet via MagicDNS, so sync traffic
# never touches Syncthing's global discovery servers or relays.
#
# ── Bootstrap order ────────────────────────────────────────────────────────
#   1. Deploy melchior (hub) with this file still all-empty:
#        nixos-rebuild switch --flake .#melchior --target-host melchior --use-remote-sudo
#   2. Read melchior's device ID:
#        ssh melchior 'journalctl -u syncthing | grep -m1 "My ID"'
#      Paste it into melchior.id below.
#   3. Deploy casper and balthasar (they each generate their own ID):
#        darwin-rebuild switch --flake .#casper
#        home-manager switch --flake .#balthasar
#   4. Read each client's device ID (run as the alongo user on that host):
#        syncthing --device-id          # or: journalctl --user -u syncthing | grep -m1 "My ID"
#      Paste them into casper.id / balthasar.id below.
#   5. Redeploy all three. The `~/sync/tasks` folder now syncs.
# ───────────────────────────────────────────────────────────────────────────
{
  melchior = {
    id = "";
    addresses = [ "tcp://melchior.taile2fc00.ts.net:22000" ];
  };
  casper = {
    id = "";
    addresses = [ "tcp://casper.taile2fc00.ts.net:22000" ];
  };
  balthasar = {
    id = "";
    addresses = [ "tcp://balthasar.taile2fc00.ts.net:22000" ];
  };
}
