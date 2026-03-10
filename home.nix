# home.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./modules/claude.nix ];
 
  sops = {
    age.keyFile = "/home/shmul95/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;

    secrets.obsidian_api_key = {};
  };

  home = {
    # home have all the var and packages installation

    username = "shmul95";
    homeDirectory = "/home/shmul95";
    stateVersion = "25.05";

    packages = with pkgs; [
      gcc gnumake nodejs
      kitty discord firefox
      sops age

      inputs.zshmul.packages.${pkgs.system}.default
      inputs.tshmux.packages.${pkgs.system}.default
      inputs.shmulvim.packages.${pkgs.system}.default

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
        if [[ $- == *i* ]]; then
          exec zshmul
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
      mcp.obsidian = {
        enable = true;
        apiKey = config.sops.secrets.obsidian_api_key.path;
        vaultPath = "/home/shmul95/.claude-memory";
      };
    };

    home-manager.enable = true;
  };

  # cursor configuration
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
    };
  };

}
