# home.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    (import ../../modules/home-manager/shmulvim.nix inputs.shmulvim)
    (import ../../modules/home-manager/tshmux.nix { inherit inputs; })
    inputs.zshmul.homeManagerModules.default
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


  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true; # Uncomment if you use X11 apps frequently
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-light";
    size = 24;
  };
  
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "shmul95";
      user.email = "samuel.gross@epitech.eu";
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      disable_ligatures = "never";
      # Enable ligatures for JetBrainsMono Nerd Font
      "font_features JetBrainsMono Nerd Font" = "+liga +calt";
    };
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

  # Install npm packages globally on rebuild
  home.activation.installNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run rm -rf ${config.xdg.dataHome}/npm/lib/node_modules/@github/copilot
    # run rm -rf ${config.xdg.dataHome}/npm/lib/node_modules/@openai/codex

    run ${pkgs.nodejs}/bin/npm install -g @github/copilot
    run chmod +x ${config.xdg.dataHome}/npm/lib/node_modules/@github/copilot/index.js
  '';

  programs.home-manager.enable = true;
}
