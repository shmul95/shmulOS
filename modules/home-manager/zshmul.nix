zshmulInput:
{ config, lib, pkgs, ... }:
let
  cfg = config.shmul.zshmul;
  zshrc = zshmulInput.outPath + "/zshrc";
  baseZshrc = builtins.readFile zshrc;
  unsafeAutostart = ''
# Auto-start tmux if not already inside tmux
[ -z "$TMUX" ] && tmux

'';
  safeAutostart = ''
# Auto-start tmux only for interactive terminals
if [[ -z "$TMUX" && $- == *i* && -t 1 ]]; then
  exec tmux
fi

'';
  patchedZshrc = lib.replaceStrings [unsafeAutostart] [safeAutostart] baseZshrc;
  customDir = zshmulInput.outPath + "/oh-my-zsh-custom";
  ohMyZshWithCustom = pkgs.runCommand "zshmul-oh-my-zsh" {} ''
    mkdir -p $out
    cp -R ${pkgs.oh-my-zsh}/share/oh-my-zsh/. $out/
    chmod -R +w $out
    rm -rf $out/custom
    cp -R ${customDir} $out/custom
  '';
in {
  options.shmul.zshmul.enable =
    lib.mkEnableOption "zsh + Oh My Zsh configuration from the zshmul flake";

  config = lib.mkMerge [
    { shmul.zshmul.enable = lib.mkDefault true; }
    (lib.mkIf cfg.enable {
      home.file.".zshrc".text = patchedZshrc;
      home.file.".oh-my-zsh".source = ohMyZshWithCustom;
    })
  ];
}
