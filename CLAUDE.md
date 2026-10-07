# nix-config ("the Magi")

One flake, three machines. README.md covers layout and day-to-day commands;
this file is what isn't obvious from it.

## Hosts and what reaches them

| Host | OS / manager | Flake output |
|------|--------------|--------------|
| casper | macOS, nix-darwin + HM (x86_64-darwin) | `darwinConfigurations.casper` |
| balthasar | Arch/Omarchy, **home-manager only** | `homeConfigurations.balthasar` |
| melchior | NixOS server | `nixosConfigurations.melchior` |

Shared files reach more than one host, so check every change against each host
it lands on:

- `home/alongo/base.nix` (+ `programs/{nvim,tmux,fish-extras}.nix`): all three
- `home/alongo/linux.nix`: balthasar, melchior
- `home/alongo/darwin.nix`: casper
- `home/alongo/dev-toolchain.nix`: casper, melchior. **Not balthasar.** Nix's
  gcc on Arch links against Nix's glibc with `/usr/lib` first on RUNPATH and
  breaks binaries at runtime (`undefined symbol: __pointer_chk_guard`).
  balthasar uses Arch gcc + rustup. Don't move compilers back into base.nix.
- `home/alongo/programs/syncthing.nix`: casper, balthasar (melchior runs
  syncthing as a system service in `hosts/melchior/services/syncthing.nix`)
- `modules/common.nix`: casper, melchior (balthasar sets nix.conf via HM in its
  own configuration.nix)
- `modules/syncthing-peers.nix`, `flake.nix`, `flake.lock`: all three

## Verifying

Use the `verify-flake` skill, or run `./scripts/check.sh` directly. Every host
can *evaluate* all three configs, but builds depend on where you are. melchior
only builds on melchior, because the Foundry zip is a `requireFile` in
melchior's store. `--melchior` builds there over SSH.

New files must be `git add`ed before anything evaluates them. Flakes ignore
untracked files.

## Deploying

The aliases live in `home/alongo/base.nix`:
`updatebalthasar`, `updatecasper`, `updatemelchior`. `updatemelchior` works
from any host and builds on melchior.

- melchior has its **own clone** of this repo and is sometimes deployed from
  it. Before deploying melchior from elsewhere, run `./scripts/check.sh --melchior`.
  It warns if melchior's clone has commits this checkout lacks, and the
  dry-activate output shows what a switch would stop or remove.
- Deploying (`switch`), pushing, and editing the Tailscale admin console are the
  user's call. Verify, then ask.
- SSH to melchior can hang on a Tailscale SSH browser check. If it does, ask
  the user to approve the link instead of retrying.

## Non-obvious constraints

- **balthasar's tailscale is pacman + systemd, not Nix.** HM can't run system
  daemons. Don't add it to the flake.
- **casper's tailscale is the Homebrew `tailscale-app` cask.** nix-darwin's
  module runs in userspace-networking mode and can't push MagicDNS settings.
- **Temporary pins and overlays** in `flake.nix` (`nixpkgs-tuxedo`, neovim
  `doCheck = false`) each say when to drop them. Check that before adding
  another workaround.
- **x86_64-darwin warning:** "Nixpkgs 26.05 will be the last release to support
  x86_64-darwin" shows up on every casper eval. It's expected and not a failure.
- **UIDs differ:** alongo is 1001 on melchior and 1000 on balthasar. That's why
  the NFS export in `hosts/melchior/services/files.nix` uses
  `all_squash,anonuid=1001`.
- **Secrets:** see `.sops.yaml` for which age keys can decrypt which file.
  casper has no age key yet. melchior decrypts with its SSH host key.

## melchior services

Each service lives in `hosts/melchior/services/<name>.nix` and is imported in
`hosts/melchior/configuration.nix`. To add one, use the `melchior-service`
skill: it covers the localhost-port + `tailscale serve` pattern, the
Tailscale console steps, and the Glance and README wiring.

## nvim/

`nvim/` is symlinked live to `~/.config/nvim` (`programs/nvim.nix`). Edits take
effect without a rebuild, so `check.sh` doesn't test them. To check that the
config loads, run `nvim --headless "+qa"` and look for errors. The NERV
colorscheme palette is in `nvim/lua/nerv/palette.lua`.

## Style

- Commit subjects: `area: lowercase summary`. The area is a host, service or
  input (`glance: …`, `melchior: …`, `flake: …`).
- Comments explain *why*: the gotcha, the workaround, when to remove it. Match
  the existing service modules.
- Prefer the stock module or the simple approach. If a custom workaround still
  has edge cases after a fix attempt, offer reverting to stock as an option.
