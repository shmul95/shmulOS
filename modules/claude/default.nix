{ config, lib, pkgs, ... }:

with lib;

let
  cfg        = config.programs.claude;
  obsidianCfg = config.programs.claude.mcp.obsidian;

  # Build the mcpServers attrset conditionally
  mcpServers = optionalAttrs obsidianCfg.enable {
    obsidian = {
      command = "npx";
      args    = [ "-y" "mcp-obsidian" obsidianCfg.vaultPath ];
      env     = {
        OBSIDIAN_API_KEY = if builtins.pathExists cfg.mcp.obsidian.apiKey
                           then builtins.readFile cfg.mcp.obsidian.apiKey
                           else cfg.mcp.obsidian.apiKey;
        OBSIDIAN_HOST     = obsidianCfg.host;
      };
    };
  };

  claudeConfig = {
    inherit mcpServers;
  };
in {
  imports = [ ./claudesidian.nix ];

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

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Write ~/.claude.json with MCP config
    home.file.".claude.json" = mkIf (mcpServers != {}) {
      text = builtins.toJSON claudeConfig;
    };

    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
      # Claude Code completions
      if command -v claude &>/dev/null; then
        source <(claude completion bash 2>/dev/null || true)
      fi
    '';

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      # Claude Code completions
      if command -v claude &>/dev/null; then
        source <(claude completion zsh 2>/dev/null || true)
      fi
    '';
  };
}
