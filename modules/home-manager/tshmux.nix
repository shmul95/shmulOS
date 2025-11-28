{ inputs }:
{ config, lib, pkgs, ... }:

let
  cfg = config.shmul.tshmux;
  tshmuxPkg = inputs.tshmux.packages.${pkgs.system}.default;
  pluginSet = inputs.tshmux.packages.${pkgs.system}.pluginSet;
  tmuxConf = builtins.readFile "${tshmuxPkg}/share/tshmux/tmux.conf";
  patchedConf = lib.replaceStrings ["/usr/bin/zsh"] ["${pkgs.zsh}/bin/zsh"] tmuxConf;
in
{
  options.shmul.tshmux.enable =
    lib.mkEnableOption "tmux setup from the tshmux flake";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      extraConfig = patchedConf;
      plugins = builtins.attrValues pluginSet;
    };
  };
}
