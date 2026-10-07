---
name: verify-flake
description: Verify nix-config changes without activating anything, picking the right checks for the machine you're running on (casper, balthasar or melchior). Use after editing any .nix file, flake.nix or flake.lock, before deploying, when asked to "check", "verify", "test" or "make sure it builds", or before running updatemelchior / updatebalthasar / updatecasper.
---

# Verify the flake

The work is done by `./scripts/check.sh`. This skill decides which flags to
pass and how to read the output.

## 1. Work out what you're verifying

```bash
git status --short && git diff --stat HEAD
```

Map the changed files to the hosts they affect. CLAUDE.md has the full list:

- `hosts/<h>/…` → `<h>` only
- `home/alongo/base.nix`, `programs/{nvim,tmux,fish-extras}.nix`, `flake.*`,
  `modules/syncthing-peers.nix` → all three hosts
- `linux.nix` → balthasar + melchior · `darwin.nix` → casper
- `dev-toolchain.nix`, `modules/common.nix` → casper + melchior
- `programs/syncthing.nix` → casper + balthasar
- `nvim/**` only → no Nix checks needed. Run `nvim --headless "+qa"` instead
  (the config is symlinked live).

If `check.sh` warns about untracked files, `git add` them (staging is enough,
no commit needed) and run it again. Flakes can't see untracked files.

## 2. Pick the flags for this machine

The script detects the host itself (`hostname -s`, or the OS as a fallback).

| On… | Always | If the change affects this host | If it affects melchior |
|-----|--------|---------------------------------|------------------------|
| balthasar | `check.sh` | `--build` (builds HM generation) | `--melchior` |
| casper | `check.sh` | `--build` (builds darwin system) | `--melchior` |
| melchior | `check.sh` | `--build` (builds locally) | `--melchior` (local dry-activate) |

Combine flags freely, e.g. `./scripts/check.sh --build --melchior`.

What can't be verified from here:
- casper can only be **evaluated** from Linux. Nothing builds x86_64-darwin
  there. Say so rather than claiming casper is verified.
- balthasar can only be evaluated from casper.
- Don't `nix build` melchior's toplevel off melchior. It tries to build ~500
  derivations and fails on the Foundry `requireFile`. `--melchior` builds it
  on melchior instead.

Run times on balthasar: plain check about 30s; `--build` adds a few seconds if
the generation is cached; `--melchior` takes 10s to a few minutes depending on
what changed.

## 3. Read the output

- `evaluation warning: Nixpkgs 26.05 will be the last release to support
  x86_64-darwin` and `Git tree … is dirty` are expected. Ignore them.
- **melchior drift warning** ("melchior's clone is at X, which this checkout
  doesn't contain") means someone committed on melchior without pushing.
  Deploying from here would roll those commits back. Tell the user, and don't
  suggest `updatemelchior` until it's resolved (push from melchior, then pull
  here). Don't push or pull yourself without asking.
- **dry-activate lines.** Compare each `would stop` / `would remove` (users,
  groups, secrets, units) with the diff. Changes the diff explains are
  expected. Anything else is drift or a mistake, so call it out by name.
  `systemd-tmpfiles-resetup.service` and a `dbus-broker` reload show up every
  time and can be ignored.
- If SSH to melchior hangs or asks for a Tailscale check, ask the user to
  approve the login link, then rerun. Don't loop.

## 4. Report

Say which hosts were evaluated, which were built, and which couldn't be
checked from this machine. Quote failures verbatim. Verification never deploys:
leave `update<host>` to the user unless they've asked you to deploy.
