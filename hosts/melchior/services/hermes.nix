{ config, inputs, pkgs, ... }:

let
  cfg = config.services.hermes-agent;

  # Native Anthropic SDK, the Telegram bot library (messaging) and the Google
  # API client (google-workspace skill: Gmail/Calendar) are opt-in
  # extras, and a Nix install can't pip them in at runtime, so bake them into
  # the sealed venv. Overriding the package here (rather than via
  # extraDependencyGroups) lets the wrapper below reference the exact build
  # the service runs.
  hermesPkg = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraDependencyGroups = [ "anthropic" "messaging" "google" ];
  };

  # Run the CLI as the service user so it shares memory/skills/sessions with
  # the gateway. Group-sharing HERMES_HOME doesn't work: Hermes chmods it 0700
  # whenever it writes auth.json (hermes_cli/auth.py, ignores managed mode).
  # cwd is the agent workspace since the hermes user can't read ~alongo.
  hermesCli = pkgs.writeShellScriptBin "hermes" ''
    exec /run/wrappers/bin/sudo -u ${cfg.user} \
      ${pkgs.coreutils}/bin/env -C ${cfg.workingDirectory} \
      HERMES_HOME=${cfg.stateDir}/.hermes \
      ${hermesPkg}/bin/hermes "$@"
  '';
in
{
  # Hermes Agent (Nous Research) — always-on personal agent, talking to the
  # Anthropic API directly. Module comes from the hermes-agent flake input.
  # State lives in /var/lib/hermes (memory, skills, sessions, cron), which the
  # restic backup already covers via /var/lib.

  # KEY=VALUE env file: ANTHROPIC_API_KEY, TELEGRAM_BOT_TOKEN,
  # TELEGRAM_ALLOWED_USERS (numeric user IDs; the bot ignores everyone else).
  sops.secrets."hermes/env" = {
    owner = cfg.user;
  };

  services.hermes-agent = {
    enable = true;
    package = hermesPkg;

    settings.model = {
      provider = "anthropic";
      default = "claude-sonnet-5-5";
    };

    # Where cron results get delivered: the Telegram DM (DM chat ID == user
    # ID). /sethome can't do this here — config.yaml is Nix-owned/read-only.
    settings.platforms.telegram.home_channel = {
      platform = "telegram";
      chat_id = "1049244523";
      name = "Home";
    };

    environmentFiles = [ config.sops.secrets."hermes/env".path ];
  };

  environment.systemPackages = [ hermesCli ];
}
