{ inputs, ... }:
{ config, lib, pkgs, ... }:

let
  cfg = config.shmul.tshmux;
  tmuxConf = ''
    # zsh default term
    set-option -g default-shell ${pkgs.zsh}/bin/zsh
    set-option -g default-command ${pkgs.zsh}/bin/zsh

    # Global color palette
    set -g @color-yellow "#FFDF32"
    set -g @color-black "#000000"
    set -g @color-gray-light "#D8DEE9"
    set -g @color-gray-medium "#ABB2BF"
    set -g @color-gray-dark "#3B4252"

    # Bind Alt-n to a new window
    bind -n M-n new-window -c "#{pane_current_path}"
    # Bind Alt-Shift-n to a new session rooted in the current path
    bind -n M-N command-prompt -p "New session name:" "new-session -A -s '%%' -c '#{pane_current_path}'"
    bind -n M-d detach-client
    bind -n M-q copy-mode

    # Bind Alt-s to session switcher
    bind -n M-s choose-tree -s

    # Bind Alt-h/j/k/l to go to specific windows
    bind -n M-h select-window -t 0
    bind -n M-j select-window -t 1
    bind -n M-k select-window -t 2
    bind -n M-l select-window -t 3
    bind -n M-H select-window -t 4
    bind -n M-J select-window -t 5
    bind -n M-K select-window -t 6
    bind -n M-L select-window -t 7

    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    bind -n M-- split-window -h  # Vertical split (side-by-side)
    bind -n M-_ split-window -v  # Horizontal split (stacked)

    bind -n M-: command-prompt

    # Bind Alt-r to restore sessions via tmux-resurrect
    bind -n M-r run-shell -b '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'

    # TPM plugin manager
    set -g @plugin 'tmux-plugins/tpm'

    # List of plugins
    set -g @plugin 'tmux-plugins/tmux-sensible'  # Good defaults
    set -g @plugin 'tmux-plugins/tmux-resurrect' # Save/restore sessions
    set -g @plugin 'tmux-plugins/tmux-continuum' # Auto-save
    set -g @plugin 'christoomey/vim-tmux-navigator' # Move between vim and tmux
    set -g @plugin 'tmux-plugins/tmux-yank' # Yank to system clipboard

    # Initialize TPM
    run '~/.tmux/plugins/tpm/tpm'

    # ---- Vi copy-mode + M-q tweaks ----
    # Use vi keys in copy-mode and status line
    set -g mode-keys vi
    set -g status-keys vi

    set -sg escape-time 0

    # Enter copy-mode with Alt-q
    unbind -n M-q
    bind -n M-q copy-mode

    # In copy-mode-vi, add vim-like selection and easy exit
    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi V send -X select-line
    bind -T copy-mode-vi Escape send -X cancel
    bind -T copy-mode-vi M-q send -X cancel

    # Also support exiting from emacs copy-mode table just in case
    bind -T copy-mode M-q send -X cancel

    bind -n M-w \
      send-keys 'codex' C-m \; \
      new-window -n nvim -c "#{pane_current_path}" -d 'nvim' \; \
      new-window -n term -c "#{pane_current_path}"

    # Resurect
    set -g @resurrect-capture-pane-contents 'on'
    set -g @continuum-restore 'on'

    set -g status-position top
    set -g status-style "fg=#{@color-yellow},bg=#{@color-black}"
    set -g status-left "#[fg=#{@color-yellow},bold]\[#S\]#[fg=#{@color-gray-light},bold] | "
    set -g status-left-length 40
    set -g window-status-format "#[fg=#{@color-gray-dark}] #W "
    set -g window-status-current-format "#[fg=#{@color-yellow},bg=#{@color-black},bold] #W "
    set -g status-right ""
    set -g message-style "fg=#{@color-gray-light},bg=#{@color-black}"
    # Copy-mode cursor line + selection styling
    set -g mode-style "fg=#{@color-gray-dark},bg=#{@color-yellow}"
    set -g copy-mode-selection-style "bg=#{@color-gray-dark}"
    set -g pane-border-style "fg=#{@color-gray-dark}"
    set -g pane-active-border-style "fg=#{@color-gray-medium}"
  '';
  localOverrides = ''
    # Ensure vi-style keys in copy mode (override any previous setting)
    set -g mode-keys vi

    # Make `y` in copy-mode-vi yank to system clipboard (Wayland) and exit
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
  '';
in
{
  options.shmul.tshmux.enable =
    lib.mkEnableOption "tmux setup from the tshmux config";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      extraConfig = tmuxConf + localOverrides;
    };
  };
}
