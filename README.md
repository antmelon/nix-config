# The Magi - Nix Configuration

Multi-machine NixOS and nix-darwin configurations named after the Magi supercomputers from Neon Genesis Evangelion.

> *"The MAGI system... It is a trinity. The three of them work together to reach the truth."*

## 🖥️ Systems

| Name | Type | OS | Status | Purpose |
|------|------|----|----|---------|
| **casper** | 🍎 MacBook Pro | nix-darwin | ✅ Active | Personal laptop (Intel x86_64) |
| **melchior** | 🖥️ Server | NixOS | 🚧 Planned | Home server, Foundry VTT, Glance dashboard |
| **balthasar** | 🖥️ Desktop | Arch | 🚧 Planned | Desktop workstation |

## 📁 Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependencies
├── .sops.yaml             # Secrets management config
├── .gitignore             # Git ignore rules
│
├── modules/
│   └── common.nix         # Shared configuration across all systems
│
├── hosts/
│   ├── casper/           # MacBook Pro configuration
│   │   └── configuration.nix
│   ├── melchior/         # Home server (future)
│   │   └── configuration.nix
│   └── balthasar/        # Desktop (future)
│       └── configuration.nix
│
├── home/
│   └── alongo/           # User dotfiles (home-manager)
│       └── default.nix
│
└── secrets/              # Encrypted secrets (safe to commit!)
    ├── casper.yaml       # Laptop secrets
    ├── melchior.yaml     # Server secrets
    ├── balthasar.yaml    # Desktop secrets
    └── shared.yaml       # Shared across all systems
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

# For macOS (casper)
sudo darwin-rebuild switch --flake .#casper

# For NixOS (melchior/balthasar)
sudo nixos-rebuild switch --flake .#<melchior/balthasar>
```

## 📝 Common Commands

### System Management

```bash
# Update casper (from casper)
updatecasper

# Update melchior
updatemelchior

# Update balthasar
updatebalthasar

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
edithome          # Edit home-manager config
editflake         # Edit flake.nix

# Quick navigation
cdnix             # Jump to config directory
```

### Secrets Management

```bash
# Edit secrets
secretcasper      # Edit casper secrets
secretmelchior    # Edit melchior secrets
secretbalthasar   # Edit balthasar secrets
secretshared      # Edit shared secrets

# View decrypted secrets
sops -d secrets/casper.yaml
```

## 🔐 Secrets Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for encrypted secrets management.

### How It Works

- Secrets are encrypted with age keys
- Each machine has its own age key pair
- Encrypted secrets are **safe to commit** to Git
- Only machines with the correct private key can decrypt

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
# Edit a secrets file (auto-decrypts for editing)
sops secrets/casper.yaml

# View decrypted (read-only)
sops -d secrets/casper.yaml
```

## ✨ Features

### Common to All Systems

- **Declarative Configuration** - Everything defined in code
- **Home Manager** - Consistent dotfiles across machines
- **Secrets Management** - Encrypted secrets with sops-nix
- **Fish Shell** - With starship prompt, eza, bat, fzf
- **Development Tools** - gcc, cmake, rust, python3
- **Git** - Pre-configured with sensible defaults

### casper (MacBook Pro)

- macOS system defaults (dock, finder, keyboard)
- Touch ID for sudo
- Caps Lock → Control remapping
- Dark mode everywhere

### melchior (Home Server) - Planned

- Foundry Virtual Tabletop
- Glance dashboard
- Tailscale for remote access
- Automatic backups

### balthasar (Desktop) - Planned

- Desktop environment
- Hardware-specific configurations

## 🛠️ Development Workflow

### Making Changes

```bash
# 1. Edit configuration
vim ~/.config/nix-config/hosts/casper/configuration.nix

# 2. Test build (doesn't activate)
darwin-rebuild build --flake ~/.config/nix-config#casper

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
Edit `modules/common.nix`

**Machine-specific:**
Edit `hosts/MACHINE/configuration.nix`

**User-specific:**
Edit `home/alongo/default.nix`

### Rollback

NixOS/nix-darwin makes rollbacks easy:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo darwin-rebuild switch --rollback

# Or select a specific generation from boot menu
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
❌ `*.key` (private keys)
❌ Unencrypted secrets
❌ `result` symlinks

The `.gitignore` is configured to protect you from accidentally committing private keys.

## 🎮 Future Plans

### melchior (Home Server)

- [ ] Install NixOS
- [ ] Add to this repository
- [ ] Set up Foundry VTT
- [ ] Configure Glance dashboard
- [ ] Set up Tailscale
- [ ] Configure automatic backups

### balthasar (Desktop)

- [ ] Install NixOS
- [ ] Add to this repository
- [ ] Desktop environment configuration
- [ ] Gaming optimizations

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
```
