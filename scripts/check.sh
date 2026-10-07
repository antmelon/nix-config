#!/usr/bin/env bash
# Verifies the flake without activating anything. Host-aware: every host can
# evaluate all three configs, but each can only *build* some of them.
#
#   ./scripts/check.sh               flake check + eval casper, balthasar, melchior
#   ./scripts/check.sh --build       + build this machine's own config
#   ./scripts/check.sh --melchior    + build on melchior and show what a switch
#                                      would change there (dry-activate)
#   ./scripts/check.sh --host NAME   override host detection
#
# Run from the repo root or any subdirectory.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BUILD=false
MELCHIOR=false
HOST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)    BUILD=true ;;
    --melchior) MELCHIOR=true ;;
    --host)     HOST="$2"; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

# Hostname first; fall back to the OS, since casper's macOS hostname isn't
# managed by nix-darwin.
if [[ -z "$HOST" ]]; then
  case "$(hostname -s)" in
    casper|balthasar|melchior) HOST="$(hostname -s)" ;;
    *)
      if [[ "$(uname -s)" == Darwin ]]; then HOST=casper
      elif [[ -e /etc/NIXOS ]]; then HOST=melchior
      else HOST=balthasar
      fi
      ;;
  esac
fi

declare -A ATTR=(
  [casper]=darwinConfigurations.casper.system
  [balthasar]=homeConfigurations.balthasar.activationPackage
  [melchior]=nixosConfigurations.melchior.config.system.build.toplevel
)
[[ -n "${ATTR[$HOST]:-}" ]] || { echo "unknown host: $HOST" >&2; exit 2; }
echo "host: $HOST"

# Flakes only see files git knows about; a new module that isn't `git add`ed
# fails with a confusing "path does not exist" error.
untracked=$(git ls-files --others --exclude-standard -- '*.nix' '*.yaml' '*.toml' '*.lua')
if [[ -n "$untracked" ]]; then
  echo ""
  echo "WARNING: untracked files are invisible to the flake (git add them):"
  echo "$untracked" | sed 's/^/  /'
fi

echo ""
echo "=== flake check ==="
nix flake check

for h in casper balthasar melchior; do
  echo ""
  echo "=== $h (eval only) ==="
  nix eval --raw ".#${ATTR[$h]}.drvPath" > /dev/null
  echo "ok"
done

if $BUILD; then
  # melchior is only built locally when we're on melchior: the Foundry zip is
  # a requireFile that only exists in melchior's store. From elsewhere, use
  # --melchior, which builds there.
  echo ""
  echo "=== $HOST (build, no activation) ==="
  nix build ".#${ATTR[$HOST]}" --no-link
  echo "ok"
fi

if $MELCHIOR; then
  rebuild=(nix run --inputs-from . nixpkgs#nixos-rebuild --)
  echo ""
  if [[ "$HOST" == melchior ]]; then
    echo "=== melchior (build + dry-activate) ==="
    "${rebuild[@]}" dry-activate --flake .#melchior --sudo
  else
    # melchior keeps its own clone and is sometimes deployed from it. If that
    # clone has commits we don't, a deploy from here would roll them back.
    echo "=== melchior (drift check) ==="
    remote_head=$(ssh -o BatchMode=yes -o ConnectTimeout=10 melchior \
      'git -C ~/.config/nix-config rev-parse HEAD' 2>/dev/null || true)
    if [[ -z "$remote_head" ]]; then
      echo "WARNING: couldn't read melchior's clone (ssh failed?)"
    elif ! git merge-base --is-ancestor "$remote_head" HEAD 2>/dev/null; then
      echo "WARNING: melchior's clone is at ${remote_head:0:7}, which this checkout doesn't contain."
      echo "  Deploying from here would drop those changes. Push them from melchior and pull here first."
    else
      echo "ok (melchior's clone is at ${remote_head:0:7}, contained in HEAD)"
    fi

    echo ""
    echo "=== melchior (build on melchior + dry-activate) ==="
    "${rebuild[@]}" dry-activate --flake .#melchior \
      --target-host melchior --build-host melchior --sudo
  fi
  echo "Review any 'would stop' / 'would remove' lines above before switching."
fi

echo ""
echo "All checks passed."
