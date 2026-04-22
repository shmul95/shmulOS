# home.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.shmulcode.homeManagerModules.default
    inputs.shmulistan.homeManagerModules.default
    inputs.shmulex.homeManagerModules.default
  ];

  sops = {
    age.keyFile = "/home/shmul95/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
  };

  home = {
    # home have all the var and packages installation

    username = "shmul95";
    homeDirectory = "/home/shmul95";
    stateVersion = "25.05";

    packages = with pkgs; [
      gcc gnumake nodejs gh
      kitty discord firefox
      sops age

      inputs.zshmul.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.tshmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.shmulvim.packages.${pkgs.stdenv.hostPlatform.system}.default

      nerd-fonts.jetbrains-mono
    ];

    sessionVariables = {
      EDITOR = "nvim"; # later on shmulvim
    };

    # linked to the gtk config
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 24;
    };

  };

  programs = {
    # basic setup of some of the application

    zsh = {
      enable = true;
      initContent = /* sh */ ''
        if [[ $- == *i* ]] && command -v tshmux >/dev/null 2>&1 && [[ -z "$TMUX" && -z "$TSHMUX" ]]; then
          tshmux
        fi
      '';
    };

    git = {
      enable = true;
      settings = {
        user.name = "shmul95";
        user.email = "samuel.gross@epitech.eu";
      };
    };

    kitty = {
      enable = true;
      settings = {
        font_family = "JetBrainsMono Nerd Font";
        disable_ligatures = "never";
        "font_features JetBrainsMono Nerd Font" = "+liga +calt";
      };
    };

    claude = {
      enable = true;
      vault.enable = true;
    };

    shmulistan.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
  };

  shmulex.source = inputs.shmulcode;

  shmulex.enable = true;

  shmulex.roles.enable = true;
  shmulex.codexAgents.enable = false;

  shmulex.claudeMcp.enable = false;
  shmulex.claudeCommands.enable = false;
  shmulex.claudeRoutingPolicy.enable = false;

  # cursor configuration
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    cursorTheme = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
    };
  };

}
