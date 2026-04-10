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
      vault.enable = false;
      package = pkgs.claude-code.overrideAttrs (old: rec {
        version = "2.1.84";
        src = pkgs.fetchzip {
          url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
          hash = "sha256-sUlqdQS8d9vha94d+/mwn+V88fiR0pzZBWezjM8Zl3Y=";
        };
        npmDepsHash = "sha256-RLgZhPnk0KrQGoULsSDPXddF2REcpakq7DmBXE2/7N0=";
        postPatch = ''
          cp ${./claude-code-2.1.84-package-lock.json} package-lock.json
          substituteInPlace cli.js \
            --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'
        '';
      });
    };

    shmulistan.enable = true;

    codex = {
      enable = true;
      source = inputs.shmulcode;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
