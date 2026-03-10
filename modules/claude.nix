{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg        = config.programs.claude;
  obsidianCfg = config.programs.claude.mcp.obsidian;

  # Wrapper script that reads the API key at runtime from a sops secret path.
  # Exits immediately if Obsidian is not reachable so claude doesn't hang.
  obsidianMcpWrapper = pkgs.writeShellScript "obsidian-mcp-wrapper" ''
    # Parse host/port from OBSIDIAN_HOST to do a quick reachability check
    HOST="${obsidianCfg.host}"
    # Strip protocol
    HOSTPORT="''${HOST#*://}"
    ADDR="''${HOSTPORT%%/*}"
    IP="''${ADDR%:*}"
    PORT="''${ADDR##*:}"

    if ! ${pkgs.curl}/bin/curl -sk --max-time 2 "$HOST" > /dev/null 2>&1; then
      echo "obsidian-mcp-wrapper: Obsidian not reachable at $HOST, exiting." >&2
      exit 1
    fi

    export OBSIDIAN_API_KEY="$(cat "${obsidianCfg.apiKey}")"
    export OBSIDIAN_HOST="${obsidianCfg.host}"
    exec ${pkgs.nodejs}/bin/npx -y mcp-obsidian "${obsidianCfg.vaultPath}"
  '';

  # Build the mcpServers attrset conditionally
  mcpServers = optionalAttrs obsidianCfg.enable {
    obsidian = {
      command = builtins.toString obsidianMcpWrapper;
      args    = [];
    };
  };

  claudeConfig = {
    inherit mcpServers;
  };
in {
  imports = [
    inputs.shmulistan.homeManagerModules.default
  ];

  # ── Claude Code ──────────────────────────────────────────────────────

  options.programs.claude = {
    enable = mkEnableOption "Claude Code";

    package = mkOption {
      type        = types.package;
      default     = pkgs.claude-code;
      description = "The Claude Code package to install.";
    };

    enableBashIntegration = mkOption {
      type    = types.bool;
      default = true;
    };

    enableZshIntegration = mkOption {
      type    = types.bool;
      default = true;
    };
  };

  # ── Obsidian MCP ─────────────────────────────────────────────────────

  options.programs.claude.mcp.obsidian = {
    enable = mkEnableOption "Obsidian MCP server for Claude Code memory";

    package = mkOption {
      type        = types.package;
      default     = pkgs.obsidian;
      description = "The Obsidian package to install.";
    };

    apiKey = mkOption {
      type    = types.str;
      default = "";
      description = ''
        Obsidian Local REST API key.
        Either the API key directly, or a path to a file containing it
        (e.g. config.sops.secrets.obsidian_api_key.path).
      '';
    };

    host = mkOption {
      type    = types.str;
      default = "https://127.0.0.1:27124";
      description = "Obsidian Local REST API host.";
    };

    vaultPath = mkOption {
      type    = types.str;
      default = "$HOME/Documents/Obsidian";
      description = "Path to your Obsidian vault.";
    };
  };

  # ── Config ───────────────────────────────────────────────────────────

  config = mkMerge [
    # Claude Code
    (mkIf cfg.enable {
      home.packages = [ cfg.package ];

      home.activation.claudeJson = mkIf (mcpServers != {}) (lib.hm.dag.entryAfter ["writeBoundary"] ''
        _src=${pkgs.writeText "claude.json" (builtins.toJSON claudeConfig)}
        _dst="$HOME/.claude.json"
        if [ -L "$_dst" ]; then
          $DRY_RUN_CMD rm "$_dst"
        fi
        if ! diff -q "$_src" "$_dst" > /dev/null 2>&1; then
          $DRY_RUN_CMD cp "$_src" "$_dst"
          $DRY_RUN_CMD chmod 644 "$_dst"
        fi
      '');

      programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
        if command -v claude &>/dev/null; then
          source <(timeout 5 claude completion bash 2>/dev/null || true)
        fi
      '';

      programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
        if (( $+commands[claude] )); then
          source <(timeout 5 claude completion zsh 2>/dev/null || true)
        fi
      '';
    })

    # Obsidian MCP
    (mkIf obsidianCfg.enable {
      home.packages = [ obsidianCfg.package ];
      assertions = [
        {
          assertion = obsidianCfg.apiKey != "";
          message   = "programs.claude.mcp.obsidian.apiKey must be set when obsidian MCP is enabled.";
        }
      ];
    })

    # Shmulistan vault
    (mkIf cfg.enable {
      programs.shmulistan.enable = true;
    })
  ];
}
