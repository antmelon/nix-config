#!/usr/bin/env bash
# Verifies all configurations evaluate correctly without activating anything.
# Run from the repo root or any subdirectory.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

FULL_BUILD=false
if [[ "${1:-}" == "--build" ]]; then
  FULL_BUILD=true
fi

echo "=== flake check ==="
nix flake check

if $FULL_BUILD; then
  echo ""
  echo "=== casper (build, no activation) ==="
  nix build .#darwinConfigurations.casper.system --no-link

  echo ""
  echo "=== balthasar (build, no activation) ==="
  nix build .#homeConfigurations.balthasar.activationPackage --no-link

  # Uncomment once melchior hardware config is in place:
  # echo ""
  # echo "=== melchior (build, no activation) ==="
  # nix build .#nixosConfigurations.melchior.config.system.build.toplevel --no-link
else
  echo ""
  echo "=== casper (eval only) ==="
  nix eval --raw .#darwinConfigurations.casper.system.drvPath > /dev/null
  echo "ok"

  echo ""
  echo "=== balthasar (eval only) ==="
  nix eval --raw .#homeConfigurations.balthasar.activationPackage.drvPath > /dev/null
  echo "ok"

  # Uncomment once melchior hardware config is in place:
  # echo ""
  # echo "=== melchior (eval only) ==="
  # nix eval --raw .#nixosConfigurations.melchior.config.system.build.toplevel.drvPath > /dev/null
  # echo "ok"
fi

echo ""
echo "All checks passed."
echo "Run with --build to do a full build (slower, catches more issues)."
