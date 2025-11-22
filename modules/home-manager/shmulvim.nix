shmulvimInput:
{ config, lib, pkgs, ... }:
let
  cfg = config.shmul.shmulvim;
  nvimSource = shmulvimInput.outPath + "/nvim";
in {
  options.shmul.shmulvim.enable =
    lib.mkEnableOption "shmul95's Neovim configuration from the shmulvim flake";

  config = lib.mkMerge [
    {
      shmul.shmulvim.enable = lib.mkDefault true;
    }
    (lib.mkIf cfg.enable {
      programs.neovim = {
        enable = true;
      };

      xdg.configFile."nvim".source = nvimSource;

      home.packages = with pkgs; [
        ripgrep
        fd
        tree-sitter
        stylua
        lua-language-server
        bash-language-server
        nodePackages.vscode-langservers-extracted
        yaml-language-server
        gopls
        pyright
        sqls
        tailwindcss-language-server
        rust-analyzer
        lazygit
      ];
    })
  ];
}
