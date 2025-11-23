{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    (import ../../modules/home-manager/shmulvim.nix inputs.shmulvim)
    (import ../../modules/home-manager/tshmux.nix inputs.tshmux)
    (import ../../modules/home-manager/zshmul.nix inputs.zshmul)
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "shmul95";
  home.homeDirectory = "/home/shmul95";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    lazygit
    nodejs
    bat

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerd-fonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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

  home.file.".npmrc".text = ''
    prefix=${config.xdg.dataHome}/npm
  '';
  
  home.sessionPath = [
    "${config.xdg.dataHome}/npm/bin"
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/shmul95/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
