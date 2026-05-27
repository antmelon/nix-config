# The Magi - Nix Configuration

Multi-machine NixOS, nix-darwin, and standalone home-manager configurations named after the Magi supercomputers from Neon Genesis Evangelion.

> *"The MAGI system... It is a trinity. The three of them work together to reach the truth."*

## 🖥️ Systems

| Name | Type | OS | Manager | Status | Purpose |
|------|------|----|---------|--------|---------|
| **casper** | 🍎 MacBook Pro | macOS | nix-darwin + home-manager | ✅ Active | Personal laptop (Intel x86_64) |
| **balthasar** | 🖥️ Desktop | Arch Linux | home-manager only | ✅ Active | Desktop workstation (x86_64) |
| **melchior** | 🖥️ Server | NixOS | NixOS + home-manager | ✅ Active | Home server: Foundry VTT, Glance, restic backups, tailscale |

## 📁 Repository Structure

```
.
├── flake.nix                       # Main flake (3 outputs: darwin/nixos/home)
├── flake.lock                      # Locked dependencies
├── .sops.yaml                      # Secrets management config
├── .gitignore                      # Git ignore rules
│
├── modules/
│   └── common.nix                  # Shared NixOS/darwin settings (gc, flakes, unfree)
│
├── hosts/
│   ├── casper/
│   │   └── configuration.nix       # nix-darwin: macOS defaults, users
│   ├── balthasar/
│   │   └── configuration.nix       # home-manager standalone entrypoint
│   └── melchior/
│       ├── configuration.nix       # NixOS: ssh, tailscale (+--ssh), users
│       ├── hardware-configuration.nix
│       └── services/
│           ├── glance.nix          # Glance dashboard + tailscale serve (svc:glances)
│           ├── foundry.nix         # Foundry VTT (via nix-foundryvtt input)
│           └── backups.nix         # Nightly restic → Backblaze B2 (sops-managed)
│
├── home/
│   └── alongo/
│       ├── base.nix                # Shared home-manager (packages, fish, git, starship)
│       ├── darwin.nix              # macOS-specific home dirs
│       ├── linux.nix               # Linux-specific home dirs + startx
│       └── programs/
│           ├── nvim.nix            # Live-edit symlink for nvim config
│           ├── tmux.nix            # tmux + catppuccin + plugins
│           └── fish-extras.nix     # Custom fish functions
│
├── nvim/                           # Neovim config (symlinked, edit live)
│   ├── init.lua
│   ├── lua/
│   ├── lazy-lock.json
│   └── KEYBINDINGS.md
│
├── scripts/
│   └── check.sh                    # Eval/build all configs without activating
│
└── secrets/                        # Encrypted secrets (safe to commit!)
    ├── casper.yaml
    └── melchior.yaml               # restic B2 creds (balthasar/shared.yaml TBD)
```

## 🚀 Quick Start

### Prerequisites

- Nix with flakes enabled
- Git
- sops and age (for secrets)

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/antmelon/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config

# casper (macOS, nix-darwin)
sudo darwin-rebuild switch --flake .#casper

# balthasar (Arch, home-manager only)
home-manager switch --flake .#balthasar

# melchior (NixOS, once installed)
sudo nixos-rebuild switch --flake .#melchior
```

### Verifying Configs

```bash
# Eval-only check of all systems (fast)
./scripts/check.sh

# Full build (slower, catches more issues)
./scripts/check.sh --build
```

## 📝 Common Commands

### System Management

```bash
# Update each machine (aliases defined in base.nix)
updatecasper       # sudo darwin-rebuild switch --flake ~/.config/nix-config#casper
updatebalthasar    # home-manager switch --flake ~/.config/nix-config#balthasar
updatemelchior     # nixos-rebuild switch --flake ... --target-host melchior --use-remote-sudo

# Update flake inputs
cd ~/.config/nix-config
nix flake update
```

### Configuration Editing

```bash
# Edit configurations
editcasper        # Edit casper config
editmelchior      # Edit melchior config
editbalthasar     # Edit balthasar config
editcommon        # Edit common module
edithome          # Edit home/alongo/base.nix
editflake         # Edit flake.nix

# Quick navigation
cdnix             # Jump to config directory
```

### Secrets Management

```bash
# Edit secrets
secretcasper      # Edit casper secrets
secretmelchior    # Edit melchior secrets (TBD)
secretbalthasar   # Edit balthasar secrets (TBD)
secretshared      # Edit shared secrets (TBD)

# View decrypted secrets
sops -d secrets/casper.yaml
```

## 🔐 Secrets Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for encrypted secrets management.

### How It Works

- Secrets are encrypted with age keys
- Each machine has its own age key pair (in addition to a personal key for any-machine edits)
- Encrypted secrets are **safe to commit** to Git
- Only machines with the correct private key can decrypt

### Current Key Set

- `personal` — root key, can decrypt everything (used for editing from any machine)
- `balthasar` — desktop key, can decrypt `balthasar.yaml`, `melchior.yaml`, and `shared.yaml`
- `melchior` — server key, can decrypt `melchior.yaml`
- `casper` — placeholder in `.sops.yaml`, not yet generated

### Adding a New Machine

1. Generate age key on the new machine:
   ```bash
   sudo mkdir -p /var/lib/sops-nix
   sudo age-keygen -o /var/lib/sops-nix/key.txt
   sudo age-keygen -y /var/lib/sops-nix/key.txt  # Get public key
   ```

2. Add public key to `.sops.yaml`

3. Re-encrypt secrets that the new machine needs:
   ```bash
   sops updatekeys secrets/MACHINE.yaml
   ```

### Editing Secrets

```bash
sops secrets/casper.yaml       # auto-decrypts for editing
sops -d secrets/casper.yaml    # view decrypted (read-only)
```

## ✨ Features

### Common to All Systems

- **Declarative Configuration** — Everything defined in code
- **Home Manager** — Consistent dotfiles across machines via `home/alongo/base.nix`
- **Secrets Management** — Encrypted secrets with sops-nix
- **Fish Shell** — With starship prompt, eza, bat, fzf, ripgrep, fd
- **Neovim (nightly)** — Pulled via `neovim-nightly-overlay`, config symlinked from `nvim/` for live editing without rebuild
- **tmux** — Catppuccin theme, resurrect/continuum, tmux-fzf, fzf-url, tmux-thumbs
- **Development Tools** — gcc, cmake, ninja, rustc, cargo, python3
- **Git** — Pre-configured with sensible defaults

### casper (MacBook Pro)

- macOS system defaults (dock, finder, keyboard)
- Touch ID for sudo
- Caps Lock → Control remapping
- Dark mode everywhere
- `yt-dlp` installed system-wide
- Tailscale with SSH (via launchd daemon, since nix-darwin's module has no `extraSetFlags`)
- `pmset -c sleep 0` so the laptop stays reachable on tailnet when plugged in

### balthasar (Arch Desktop)

- Home-manager only (Arch handles the system layer)
- Auto-`startx` on tty1 login via fish login-shell init
- Shares `base.nix` + `linux.nix` with melchior's home config

### melchior (Home Server)

- Foundry Virtual Tabletop (via `nix-foundryvtt`, tailnet-only)
- Glance dashboard, exposed at `https://glances/` via Tailscale Service (svc:glances)
- Tailscale with SSH enabled (`extraSetFlags = [ "--ssh" ]`)
- Nightly restic backups to Backblaze B2 (sops-managed credentials)
- Per-service modules under `hosts/melchior/services/`

## 🛠️ Development Workflow

### Making Changes

```bash
# 1. Edit configuration
vim ~/.config/nix-config/hosts/casper/configuration.nix

# 2. Verify it evaluates
./scripts/check.sh

# 3. Apply changes
updatecasper

# 4. Commit
cd ~/.config/nix-config
git add -A
git commit -m "Update casper configuration"
git push
```

### Adding Packages

**System-wide (all machines):**
Edit `home/alongo/base.nix` (the `home.packages` list)

**Machine-specific (system layer):**
Edit `hosts/MACHINE/configuration.nix`

**Per-platform home-manager:**
Edit `home/alongo/darwin.nix` or `home/alongo/linux.nix`

### Rollback

NixOS/nix-darwin makes rollbacks easy:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo darwin-rebuild switch --rollback

# Or select a specific generation from boot menu (NixOS)
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

## 🎮 Future Plans

### melchior (Home Server)

- [x] Install NixOS, fill in `hardware-configuration.nix`
- [x] Generate machine age key, add to `.sops.yaml`
- [x] Set up Foundry VTT
- [x] Configure Glance dashboard
- [x] Set up Tailscale (declarative, with `--ssh`)
- [x] Configure automatic backups (restic → B2)

### balthasar (Desktop)

- [x] Bring under home-manager
- [x] Generate age key, wire up sops
- [ ] Migrate from standalone home-manager to full NixOS (eventually)
- [ ] Gaming optimizations
- Note: tailscale stays on `pacman` until full NixOS migration — home-manager standalone can't manage system daemons cleanly

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
