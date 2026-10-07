# The Magi - Nix Configuration

Multi-machine NixOS, nix-darwin, and standalone home-manager configurations named after the Magi supercomputers from Neon Genesis Evangelion.

> *"The MAGI system... It is a trinity. The three of them work together to reach the truth."*

## 🖥️ Systems

| Name | Type | OS | Manager | Status | Purpose |
|------|------|----|---------|--------|---------|
| **casper** | 🍎 MacBook Pro | macOS | nix-darwin + home-manager | ✅ Active | Personal laptop (Intel x86_64) |
| **balthasar** | 🖥️ Desktop | Arch Linux (Omarchy) | home-manager only | ✅ Active | Desktop workstation (x86_64) |
| **melchior** | 🖥️ Server | NixOS | NixOS + home-manager | ✅ Active | Home server: self-hosted apps on the tailnet, LAN DNS, file/music hub, backups |

All three are joined to one Tailscale tailnet (`taile2fc00.ts.net`) and reach each other by MagicDNS name (`ssh melchior`).

## 📁 Repository Structure

```
.
├── flake.nix                       # Main flake (3 outputs: darwin/nixos/home) + overlays
├── flake.lock                      # Locked dependencies
├── .sops.yaml                      # Which age keys can decrypt which secrets file
├── CLAUDE.md                       # Notes for AI agents working in this repo
├── .claude/skills/                 # verify-flake, melchior-service
│
├── modules/
│   ├── common.nix                  # casper + melchior: flakes, unfree, gc, store optimise
│   └── syncthing-peers.nix         # Syncthing device IDs for all three hosts
│
├── hosts/
│   ├── casper/
│   │   └── configuration.nix       # nix-darwin: macOS defaults, Homebrew tailscale, sshd
│   ├── balthasar/
│   │   └── configuration.nix       # home-manager standalone entrypoint
│   └── melchior/
│       ├── configuration.nix       # NixOS: users, ssh, tailscale, firewall, service imports
│       ├── hardware-configuration.nix
│       └── services/               # One module per service (see melchior below)
│           ├── adguard.nix
│           ├── backups.nix
│           ├── devstack.nix
│           ├── dm-assistant.nix
│           ├── files.nix
│           ├── foundry.nix
│           ├── glance.nix
│           ├── hermes.nix
│           ├── navidrome.nix
│           ├── syncthing.nix
│           └── vaultwarden.nix
│
├── home/
│   └── alongo/
│       ├── base.nix                # All hosts: packages, fish, git, starship, direnv
│       ├── dev-toolchain.nix       # casper + melchior: gcc, cmake, ninja, rustc, cargo
│       ├── darwin.nix              # casper: home dir
│       ├── linux.nix               # balthasar + melchior: home dir
│       └── programs/
│           ├── nvim.nix            # Live-edit symlink for nvim config
│           ├── tmux.nix            # tmux + catppuccin + plugins
│           ├── fish-extras.nix     # NERV greeting + custom fish functions
│           ├── starship.toml       # Prompt (literal TOML so Nerd Font glyphs survive)
│           └── syncthing.nix       # casper + balthasar: Syncthing client
│
├── nvim/                           # Neovim config (symlinked, edit live)
│   ├── init.lua
│   ├── lua/config/                 # options, keymaps, autocmds, lazy bootstrap
│   ├── lua/plugins/                # lsp, completion, treesitter, snacks, harpoon, …
│   ├── lua/nerv/ + colors/nerv.lua # NERV colorscheme + lualine theme
│   ├── lazy-lock.json
│   └── KEYBINDINGS.md
│
├── templates/
│   └── polyglot-devshell/          # node/python/go/rust devshell wired to melchior's devstack
│
├── scripts/
│   └── check.sh                    # Host-aware eval/build/dry-activate, never activates
│
└── secrets/                        # Encrypted secrets (safe to commit!)
    ├── casper.yaml                 # Not consumed by any config yet
    └── melchior.yaml               # restic B2 creds, Hermes env
```

## 🚀 Quick Start

### Prerequisites

- Nix with flakes enabled
- Git
- sops and age (for secrets)

### Initial Setup

```bash
# Clone the repository
git clone git@github.com:antmelon/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config

# casper (macOS, nix-darwin)
sudo darwin-rebuild switch --flake .#casper

# balthasar (Arch, home-manager only). The first run needs flakes enabled by
# hand; afterwards home-manager writes ~/.config/nix/nix.conf itself.
NIX_CONFIG="experimental-features = nix-command flakes" \
  home-manager switch --flake .#balthasar

# melchior (NixOS) — on melchior itself
sudo nixos-rebuild switch --flake .#melchior
```

### Verifying Configs

`scripts/check.sh` never activates anything. Every host can evaluate all three configs, but each one can only build some of them.

```bash
# flake check + eval all three systems (fast, works from any host)
./scripts/check.sh

# + build this machine's own config (no activation)
./scripts/check.sh --build

# + build on melchior and show what a switch would change there; also warns
#   if melchior's clone has commits this checkout doesn't
./scripts/check.sh --melchior
```

melchior can only be fully built **on melchior**: the Foundry zip is a `requireFile` that exists only in its store. `--melchior` builds it there over SSH. casper can only be evaluated from Linux, not built.

## 📝 Common Commands

### System Management

```bash
# Apply each machine (aliases defined in base.nix)
updatecasper       # sudo darwin-rebuild switch --flake ~/.config/nix-config#casper
updatebalthasar    # home-manager switch --flake ~/.config/nix-config#balthasar
updatemelchior     # nixos-rebuild switch for melchior; works from any host, builds on melchior

# Update flake inputs
cd ~/.config/nix-config
nix flake update                    # everything
nix flake update hermes-agent       # bump Hermes deliberately (see flake.nix)
```

melchior keeps its own clone of this repo and can be deployed from it. Before running `updatemelchior` from another machine, run `./scripts/check.sh --melchior`. If melchior has commits you haven't pulled, deploying would roll them back.

### Configuration Editing

```bash
editcasper        # Edit casper config
editmelchior      # Edit melchior config
editbalthasar     # Edit balthasar config
editcommon        # Edit common module
edithome          # Edit home/alongo/base.nix
editflake         # Edit flake.nix
cdnix             # Jump to config directory
```

### Secrets

```bash
secretmelchior    # sops secrets/melchior.yaml
secretcasper      # sops secrets/casper.yaml
secretbalthasar   # sops secrets/balthasar.yaml (file doesn't exist yet)
secretshared      # sops secrets/shared.yaml   (file doesn't exist yet)
```

### Everyday

```bash
t                 # tuxedo on ~/sync/tasks/todo.txt (synced across the Magi)
finish            # rename current dir to <name>_COMPLETED and cd out
psmem10           # top 10 processes by memory
```

## 🔐 Secrets Management

Secrets are encrypted with [sops](https://github.com/getsops/sops) + age and committed to git. **Only melchior consumes secrets at activation**, through [sops-nix](https://github.com/Mic92/sops-nix). It decrypts with its SSH host key (`/etc/ssh/ssh_host_ed25519_key`). On the other hosts, sops is only for editing (`SOPS_AGE_KEY_FILE=~/.config/sops/age/personal.txt`).

### Current Key Set

- `personal` — root key, can decrypt everything (used for editing from any machine)
- `balthasar` — can decrypt `balthasar.yaml`, `melchior.yaml`, and `shared.yaml`
- `melchior` — can decrypt `melchior.yaml` (derived from its SSH host key)
- `casper` — placeholder in `.sops.yaml`, not yet generated

### What's in `melchior.yaml`

| Key | Used by |
|-----|---------|
| `restic/password`, `restic/env` | Nightly B2 backups (`backups.nix`) |
| `hermes/env` | Hermes Agent: `ANTHROPIC_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_ALLOWED_USERS` |

### Adding a New Machine

1. Generate an age key on the new machine (or derive one from its SSH host key with `ssh-to-age`):
   ```bash
   sudo mkdir -p /var/lib/sops-nix
   sudo age-keygen -o /var/lib/sops-nix/key.txt
   sudo age-keygen -y /var/lib/sops-nix/key.txt  # Get public key
   ```
2. Add the public key to `.sops.yaml`.
3. Re-encrypt the secrets the new machine needs:
   ```bash
   sops updatekeys secrets/MACHINE.yaml
   ```

## ✨ Features

### Common to All Systems (`base.nix`)

- **Home Manager**: consistent dotfiles across machines
- **Fish shell**: starship prompt (custom `starship.toml`), NERV greeting, eza/bat/fzf/ripgrep/fd, and "better default" aliases (`cat`→bat, `ls`→eza, `grep`→rg, `find`→fd)
- **Neovim (nightly)**: from `neovim-nightly-overlay`. The config is symlinked from `nvim/`, so edits take effect without a rebuild. Uses the NERV colorscheme.
- **tmux**: Catppuccin theme, resurrect/continuum, tmux-fzf, fzf-url, tmux-thumbs
- **direnv + nix-direnv**: per-project devshells (see `templates/`)
- **Git**: name/email, `main` default branch, rebase on pull
- **tuxedo**: todo.txt TUI on `~/sync/tasks/todo.txt`, which Syncthing keeps in sync
- **python3**. The compilers are in `dev-toolchain.nix` and aren't installed on every host (see below).

### Syncthing (`~/sync/tasks`)

Hub-and-spoke: melchior runs the always-on hub as a system service, and casper and balthasar run home-manager clients that only peer with melchior. Device IDs live in `modules/syncthing-peers.nix`. Traffic is pinned to the tailnet, with global discovery, relays and NAT traversal turned off. The folder is fully declarative, so changes made in the GUI are reverted on restart.

### casper (MacBook Pro)

- macOS defaults: autohide dock, Finder path bar and extensions, fast key repeat, dark mode
- Caps Lock → Control
- `yt-dlp` system-wide
- Nix compilers (`dev-toolchain.nix`)
- **Tailscale** from the Homebrew `tailscale-app` cask. nix-darwin's module runs in userspace-networking mode and can't push MagicDNS to macOS.
- **Remote Login (sshd)** turned on, so `ssh alongo@casper` works over the tailnet. The Tailscale app is sandboxed and can't do Tailscale SSH.
- `pmset -c sleep 0` keeps the laptop reachable on the tailnet while plugged in

### balthasar (Arch Desktop)

- Home-manager only; Arch/Omarchy handles the system layer
- Writes its own `~/.config/nix/nix.conf` (flakes) via HM, since there's no system module
- **Uses Arch's gcc + rustup, not Nix compilers.** Nix's gcc on Arch produces binaries that load Nix's `ld.so` with Arch's `libc` and crash at startup.
- Desktop session is Omarchy's SDDM autologin into Hyprland (outside this repo)
- **Tailscale** via `pacman` + systemd, outside this repo (HM can't manage system daemons)
- **melchior's file share** is mounted over NFS at `~/melchior` (fstab automount, outside this repo), and `~/Music` symlinks into it for omatunes

### melchior (Home Server)

Each web app listens on a local port (`127.0.0.1` where the module allows it; the firewall only opens 22 and 53 to the LAN) and is published to the tailnet as a **Tailscale Service** at `https://<name>.taile2fc00.ts.net` by a `tailscale-serve-<name>` oneshot unit. There's no reverse proxy, and `tailscale0` is a trusted firewall interface. Adding one is covered by the `melchior-service` skill.

| Service | URL | Module | Notes |
|---------|-----|--------|-------|
| **Glance** dashboard | `https://glances.taile2fc00.ts.net` | `glance.nix` | Health monitors + bookmarks for everything below |
| **Foundry VTT** v14 | `https://melchior.taile2fc00.ts.net/foundry` | `foundry.nix` | ⚠️ **Public** via Tailscale Funnel so players can join without the tailnet |
| **Vaultwarden** | `https://vault.taile2fc00.ts.net` | `vaultwarden.nix` | Tailnet only, never funneled |
| **AdGuard Home** | `https://adguard.taile2fc00.ts.net` | `adguard.nix` | Also **DNS for the whole LAN** on :53; original router DNS recorded in the module |
| **Mailpit** | `https://mail.taile2fc00.ts.net` | `devstack.nix` | Part of the dev stack below |
| **DM Assistant** | `https://dm-assistant.taile2fc00.ts.net` | `dm-assistant.nix` | Static SPA from the `dm-assistant` flake input |
| **File Browser** | `https://files.taile2fc00.ts.net` | `files.nix` | Web UI over `~/files`; first-run admin password is in the journal |
| **Navidrome** | `https://music.taile2fc00.ts.net` | `navidrome.nix` | Music server + Subsonic API over `~/files/Music` |

Also on melchior:

- **Hermes Agent** (`hermes.nix`): an always-on personal agent from Nous Research's `hermes-agent` flake. It talks to the Anthropic API (Claude Sonnet) and is reached through a Telegram bot limited to allowed user IDs. Cron results go to that Telegram DM. The `hermes` CLI on melchior runs as the service user, so it shares memory, skills and sessions with the gateway. State lives in `/var/lib/hermes`.
- **File hub** (`files.nix`): `~/files/{Music,Documents}` exported over **NFS** to balthasar's tailnet IP. `all_squash` maps every access to alongo, because the uid is 1001 here and 1000 on balthasar.
- **Dev stack** (`devstack.nix`): Podman (with a `docker` alias) runs Postgres 16, Redis 7 and Mailpit on localhost for remote development. aardvark-dns is disabled so it doesn't collide with AdGuard on :53.
- **Syncthing hub** (`syncthing.nix`): GUI on loopback only (`ssh -L 8384:127.0.0.1:8384 melchior`)
- **Backups** (`backups.nix`): nightly restic to Backblaze B2 for `/home` and `/var/lib` (minus caches), keeping 7 daily, 4 weekly and 6 monthly
- **Tailscale** with `--ssh`, plus OpenSSH with keys only
- Nix compilers, `nix-ld` for prebuilt binaries, and passwordless sudo for alongo (needed for remote `nixos-rebuild --sudo`)

## 🧩 Flake Inputs & Overlays

| Input | Why |
|-------|-----|
| `nixpkgs` (unstable) | Base package set for everything |
| `nix-darwin`, `home-manager`, `sops-nix` | System/home/secrets modules |
| `neovim-nightly-overlay` | Nightly Neovim |
| `foundryvtt` | Foundry module; the package is rebuilt through our `pkgs` so `allowUnfree` applies |
| `dm-assistant` | The DM Assistant site served on melchior |
| `hermes-agent` | Hermes module + package; deliberately **doesn't** follow our nixpkgs |
| `nixpkgs-tuxedo` (master) | **Temporary.** Supplies `tuxedo` until nixpkgs-unstable has it |

Overlays in `flake.nix`, each with a removal condition noted in place:
- Nightly Neovim builds with `doCheck = false` (its test suite fails under nixpkgs 26.11)
- `tuxedo` comes from the pinned master input

## 🛠️ Development Workflow

### Making Changes

```bash
# 1. Edit configuration
nvim ~/.config/nix-config/hosts/melchior/services/foo.nix

# 2. New files must be tracked, or the flake can't see them
git add -A

# 3. Verify
./scripts/check.sh --build          # add --melchior for server changes

# 4. Apply
updatemelchior

# 5. Commit + push
git commit -m "melchior: add foo"
git push
```

### Adding Packages

- **All machines:** `home/alongo/base.nix` (`home.packages`)
- **Compilers / build tools:** `home/alongo/dev-toolchain.nix` (casper + melchior only, so not balthasar)
- **Machine-specific system layer:** `hosts/MACHINE/configuration.nix`
- **Per-platform home-manager:** `home/alongo/darwin.nix` or `home/alongo/linux.nix`

### Project Devshells

`templates/polyglot-devshell` gives you node 22 + pnpm, Python 3.12 + uv, Go, and stable Rust, plus Postgres/Redis clients, with `DATABASE_URL`, `REDIS_URL` and SMTP pointing at the devstack ports. It isn't exported as a flake template, so copy it into a project:

```bash
cp ~/.config/nix-config/templates/polyglot-devshell/{flake.nix,.envrc} .
direnv allow
```

It's x86_64-linux only as written.

### Rollback

```bash
# casper
sudo darwin-rebuild switch --rollback

# melchior (or pick an older generation from the systemd-boot menu)
ssh melchior sudo nixos-rebuild switch --rollback

# balthasar
home-manager generations                  # find the generation's store path
/nix/store/<hash>-home-manager-generation/activate
```

## 📚 Useful Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)

## 🔒 Security

### Safe to Commit

✅ All `.nix` configuration files
✅ `.sops.yaml` (contains only **public** keys)
✅ `secrets/*.yaml` (encrypted files)
✅ `flake.lock`

### Never Commit

❌ `*.txt` (age private keys)
❌ `*.key` / `*.pem` / `*.priv` (private keys)
❌ Unencrypted secrets
❌ `result` symlinks

The `.gitignore` is configured to protect you from accidentally committing private keys.

### Exposure

- **Public internet:** Foundry only (Tailscale Funnel)
- **LAN:** SSH (22) and AdGuard DNS (53) on melchior; the firewall closes every other port
- **Tailnet only:** everything else (`tailscale0` is a trusted interface)
- melchior has its own GitHub SSH key so it can push this repo

## 🎮 Future Plans

### melchior (Home Server)

- [x] Install NixOS, fill in `hardware-configuration.nix`
- [x] Generate machine age key, add to `.sops.yaml`
- [x] Set up Foundry VTT
- [x] Configure Glance dashboard
- [x] Set up Tailscale (declarative, with `--ssh`)
- [x] Configure automatic backups (restic → B2)
- [x] Self-hosted apps: Vaultwarden, AdGuard, File Browser, Navidrome, DM Assistant, Hermes

### balthasar (Desktop)

- [x] Bring under home-manager
- [x] Generate age key (for editing secrets)
- [ ] Migrate from standalone home-manager to full NixOS (eventually)
- [ ] Gaming optimizations
- Note: tailscale stays on `pacman` until full NixOS migration — home-manager standalone can't manage system daemons cleanly

### casper (MacBook Pro)

- [ ] Generate casper's age key and enable it in `.sops.yaml`
- [ ] Plan ahead: nixpkgs 26.05 is the last release supporting x86_64-darwin

### Repo

- [ ] Drop the `nixpkgs-tuxedo` pin once nixpkgs-unstable ships tuxedo
- [ ] Drop the neovim `doCheck = false` overlay once the nightly test suite builds again
- [ ] Export `templates/polyglot-devshell` as a flake template

## 🤝 Contributing

This is a personal configuration repository, but feel free to:

- Use it as inspiration for your own configs
- Open issues if you spot problems
- Submit PRs for typos or improvements

## 📄 License

MIT License - Feel free to use and modify as you see fit.

## 🙏 Acknowledgments

Configuration inspired by:
- [Mic92's dotfiles](https://github.com/Mic92/dotfiles)
- [hlissner's dotfiles](https://github.com/hlissner/dotfiles)
- The NixOS community

---

*"Mankind's greatest invention is the computer. It is the ultimate tool to carry out the will of man."*
