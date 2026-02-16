# NixOS Configuration Repository

Multi-machine configuration management.

## Machines

- **MacBook-Pro-4** - Intel MacBook Pro with nix-darwin
- **homeserver** - (Coming soon) Home server with Foundry VTT

## Quick Commands
```bash
# Update Mac
darwin-rebuild switch --flake .#MacBook-Pro-4

# Update flake inputs
nix flake update

# Build without switching
darwin-rebuild build --flake .#MacBook-Pro-4
```
