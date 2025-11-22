tshmuxInput:
{ config, lib, pkgs, ... }:

let
  cfg = config.shmul.tshmux;
  tmuxConf = "${tshmuxInput}/tmux.conf";
  pluginsDir = "${tshmuxInput}/plugins";
  installScript = "${tshmuxInput}/install.sh";
  pluginsAvailable =
    let
      entries =
        if builtins.pathExists pluginsDir then
          builtins.attrNames (builtins.readDir pluginsDir)
        else
          [ ];
    in entries != [ ];
  installScriptAvailable = builtins.pathExists installScript;
in
{
  options.shmul.tshmux.enable = lib.mkEnableOption "tmux setup (tshmux)";

  config = lib.mkIf cfg.enable {
    programs.tmux.enable = true;

    home.file =
      {
        ".tmux.conf".source = tmuxConf;
      }
      // lib.optionalAttrs pluginsAvailable {
        ".tmux/plugins".source = pluginsDir;
      };

    home.activation = lib.optionalAttrs installScriptAvailable {
      tshmuxInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cd ${tshmuxInput}
        ${pkgs.bash}/bin/bash ./install.sh
      '';
    };
  };
}
