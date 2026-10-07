---
name: melchior-service
description: Add (or expose) a self-hosted service on melchior, the NixOS home server, as a Tailscale Service at https://<name>.taile2fc00.ts.net. Covers the NixOS module, the tailscale-serve unit, the Tailscale admin-console steps (and the order they must happen in), Glance/README wiring, and post-deploy checks. Use when asked to host, run, set up, add or expose an app/server/dashboard on melchior or "on the server".
---

# Add a service to melchior

Every melchior service follows the same pattern: the app listens on
`127.0.0.1:<port>`, a oneshot unit publishes it with `tailscale serve` as
`svc:<name>`, and the tailnet reaches it at `https://<name>.taile2fc00.ts.net`.
There's no nginx or caddy, and no firewall ports, because `tailscale0` is
trusted wholesale.

Templates to copy from: `hosts/melchior/services/navidrome.nix` (nixpkgs
module), `dm-assistant.nix` (flake input + static site), `devstack.nix` (OCI
container).

## 1. Check prerequisites

- **Is there a nixpkgs module?** Prefer it to a container. Check what options
  it takes:
  ```bash
  nix eval --json .#nixosConfigurations.melchior.options.services.<name> --apply builtins.attrNames
  ```
  To read the module source: `nix eval --raw .#nixosConfigurations.melchior.pkgs.path`,
  then open `nixos/modules/services/…`.
- **Pick a free port.** List the ports already in use:
  ```bash
  grep -rnoE '(127\.0\.0\.1|0\.0\.0\.0):[0-9]+|[Pp]ort = [0-9]+' hosts/melchior | sort -t: -k3 -u
  ssh melchior 'ss -tlnH' | awk '{print $4}' | sort -u   # catches ports set outside this repo
  ```
  Port 53 belongs to AdGuard. Don't enable anything that binds DNS (that's why
  podman's `dns_enabled = false`).
- **Pick the svc name.** Existing names: run `grep -rhoE 'svc:[a-z-]+' hosts/melchior | sort -u`.
  Use a short, lowercase name. It becomes the hostname.

## 2. Tell the user about the Tailscale console steps *before* deploying

These are the user's to do in the admin console, so hand them over early:

1. **Services → create `svc:<name>`** with endpoint `tcp:443`.
2. **Access controls (policy file):** add `"svc:<name>": ["tag:home-server"]`
   to `autoApprovers`. The existing `src: *, dst: *` grant already allows
   access, so no grant change is needed.

Order matters. If melchior advertises the service before it exists in the
console, the console never registers melchior as its host, and re-running
`advertise` doesn't help. Recovery (on melchior):
```bash
sudo tailscale serve drain svc:<name>
sudo tailscale serve advertise svc:<name>
# within ~30s the service IP should show up in melchior's AllowedIPs:
tailscale status --json | jq -r '.Self.AllowedIPs[]'
```

## 3. Write `hosts/melchior/services/<name>.nix`

Start with a comment saying what the service is and where it's reachable. Bind
to loopback. Then add the serve unit, copied exactly from the other modules:

```nix
{ pkgs, ... }:

# <What it is>, exposed as svc:<name> (https://<name>/).
let
  port = <port>;
in
{
  services.<name> = {
    enable = true;
    # bind to 127.0.0.1:${toString port}, using whatever option names the module has
  };

  # Expose <App> as svc:<name> on the tailnet (https://<name>/).
  systemd.services.tailscale-serve-<name> = {
    description = "Advertise <App> as Tailscale Service svc:<name>";
    after = [ "tailscaled.service" "network-online.target" "<unit>.service" ];
    wants = [ "network-online.target" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for _ in $(seq 1 30); do
        ${pkgs.tailscale}/bin/tailscale status --self=true --peers=false >/dev/null 2>&1 && break
        sleep 1
      done
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:<name> --bg --https=443 http://127.0.0.1:${toString port}
      ${pkgs.tailscale}/bin/tailscale serve --service=svc:<name> advertise svc:<name>
    '';
  };
}
```

For something that must be reachable from the **public internet** (like
Foundry for friends), use Funnel instead. See `foundry.nix`. It needs the
`funnel` node attribute in the ACL and uses a path on melchior's own hostname,
not a svc. Confirm with the user before exposing anything publicly. Never do
it for password, file or admin UIs.

### Known pitfalls

- **Data under `/home`:** many modules set `ProtectHome = true`, which hides
  `/home` even from a service running as alongo. Use
  `systemd.services.<unit>.serviceConfig.ProtectHome = lib.mkForce "tmpfs";`
  and bind only the folder it needs (see `navidrome.nix`).
- **Running as alongo** (`user = "alongo"; group = "users";`) is the pattern
  when the service shares files with File Browser, NFS or syncthing. A module
  only auto-creates `/var/lib/<name>` for its *default* user, so override
  `dataDir` too (see `syncthing.nix`).
- **Secrets** go in `secrets/melchior.yaml` through sops-nix
  (`sops.secrets."<name>/…"`, see `backups.nix`). Editing that file is the
  user's job (`secretmelchior`). Tell them which keys to add, and never put
  plaintext secrets in a .nix file.
- **First-run credentials** (random admin passwords printed to the journal,
  signup toggles): mention them in the module comment and in your summary.

## 4. Wire it up

- Add `./services/<name>.nix` to the imports in `hosts/melchior/configuration.nix`.
- `hosts/melchior/services/glance.nix`: add a **monitor** entry (`url` = the
  ts.net URL, `check-url` = `http://127.0.0.1:<port>/<health path>`) and a
  **bookmark**, in the same order as the existing ones.
- `README.md`: add the module to the services tree and the melchior features list.
- Backups: `backups.nix` covers `/home` and `/var/lib`. If the service keeps
  state anywhere else, add that path.
- `git add` the new file.

## 5. Verify, deploy, check

1. Use the `verify-flake` skill (`./scripts/check.sh --melchior`). Check that
   dry-activate *starts* the new units, and look for drift warnings.
2. Confirm the console steps are done, then deploy (`updatemelchior`), after
   the user agrees.
3. Check the service from balthasar or casper:
   ```bash
   ssh melchior 'systemctl is-active <unit> tailscale-serve-<name>; curl -fsS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:<port>/'
   getent hosts <name>.taile2fc00.ts.net
   curl -sS -o /dev/null -w '%{http_code}\n' --max-time 30 https://<name>.taile2fc00.ts.net/
   ```
   If the name doesn't resolve or the connection times out, it's almost
   always the console order problem in step 2. Use the drain and re-advertise
   steps there.

Commit subject: `melchior: <what>` or `<name>: <what>`.
