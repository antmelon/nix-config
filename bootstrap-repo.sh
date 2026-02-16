#!/usr/bin/env bash
# Bootstrap script for NixOS configuration repository
# This sets up the directory structure and template files

set -e

echo "🚀 NixOS Configuration Repository Bootstrap"
echo "=========================================="
echo ""

# Get the repository directory
REPO_DIR="${1:-$HOME/nixos-config}"

echo "Creating repository structure in: $REPO_DIR"
echo ""

# Create directory structure
mkdir -p "$REPO_DIR"/{hosts/{homeserver,desktop,laptop},modules,secrets,home/ant/programs}

# Copy template files (you'll need to manually copy these from the guide)
echo "Creating template files..."

cat > "$REPO_DIR/.gitignore" << 'EOF'
# Build outputs
result
result-*

# Age private keys - NEVER COMMIT THESE
*.txt
*.key
*.pem
*.priv

# Backup files
*.bak
*~

# OS files
.DS_Store
Thumbs.db

# Don't ignore encrypted secrets - they're safe!
!secrets/*.yaml
EOF

cat > "$REPO_DIR/README.md" << 'EOF'
# NixOS Configuration

Personal NixOS configurations managed with flakes and sops-nix.

## Quick Start

See the full README template for complete instructions.

## Systems

- homeserver
- desktop  
- laptop

## Secrets

Managed with sops-nix. See GIT_SECRETS_MANAGEMENT.md for setup.
EOF

# Initialize git
cd "$REPO_DIR"
git init

echo "✅ Directory structure created"
echo ""
echo "📋 Next steps:"
echo "1. Copy your existing configuration files to hosts/"
echo "2. Set up sops-nix following GIT_SECRETS_MANAGEMENT.md"
echo "3. Create flake.nix (see template-flake.nix)"
echo "4. Generate age keys for each machine"
echo "5. Create and encrypt secrets/"
echo "6. Commit and push to GitHub"
echo ""
echo "Repository initialized at: $REPO_DIR"
