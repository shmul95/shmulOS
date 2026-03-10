{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.claude.mcp.obsidian;
in {
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
        Either the API key directly, or a path to a file containing it (e.g. config.sops.secrets.obsidian_api_key.path).
      '';
    };

    host = mkOption {
      type    = types.str;
      default = "https://127.0.0.1:27124";
      description = "Obsidian Local REST API host (check the plugin settings for HTTP vs HTTPS and port).";
    };

    vaultPath = mkOption {
      type    = types.str;
      default = "$HOME/Documents/Obsidian";
      description = "Path to your Obsidian vault (used in VAULT_PATH env var for context).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    assertions = [
      {
        assertion = cfg.apiKey != "";
        message   = "programs.claude.mcp.obsidian.apiKey must be set when obsidian MCP is enabled.";
      }
    ];
  };
}
