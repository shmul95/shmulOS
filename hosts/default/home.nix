{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    (import ../../modules/home-manager/shmulvim.nix inputs.shmulvim)
    (import ../../modules/home-manager/tshmux.nix { inherit inputs; })
    (import ../../modules/home-manager/zshmul.nix)
  ];

  home.username = "shmul95";
  home.homeDirectory = "/home/shmul95";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    gcc gnumake nodejs
    kitty lazygit bat tree
    discord
    xclip wl-clipboard
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs.git = {
    enable = true;
    userName = "shmul95";
    userEmail = "samuel.gross@epitech.eu";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source /etc/profiles/per-user/${config.home.username}/etc/profile.d/hm-session-vars.sh

      if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" && $- == *i* && -t 1 ]]; then
        exec tmux
      fi
    '';
  };

  shmul.tshmux.enable = true;

  home.file.".npmrc".text = ''
    prefix=${config.xdg.dataHome}/npm
  '';

  home.sessionPath = [
    "${config.xdg.dataHome}/npm/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
