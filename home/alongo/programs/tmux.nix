{ pkgs, ... }:

{
  programs.tmux = {
    enable      = true;
    baseIndex   = 1;
    escapeTime  = 0;
    historyLimit = 1000000;
    keyMode     = "vi";
    mouse       = true;
    terminal    = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      catppuccin
      tmux-fzf
      fzf-tmux-url
      tmux-thumbs
    ];

    extraConfig = ''
      set-option -g terminal-overrides ',xterm-256color:RGB'
      set-option -g detach-on-destroy off
      set-option -g renumber-windows on
      set-option -g set-clipboard on
      set-option -g status-position top
      set-option -g focus-events on

      set-option -g pane-active-border-style 'fg=magenta,bg=default'
      set-option -g pane-border-style 'fg=brightblack,bg=default'

      # Continuum/resurrect
      set -g @continuum-restore 'on'
      set -g @resurrect-strategy-nvim 'session'

      # Catppuccin
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"
      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
      set -g @catppuccin_status_modules_right "directory date_time"
      set -g @catppuccin_status_modules_left "session"
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator " "
      set -g @catppuccin_status_right_separator_inverse "no"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"
      set -g @catppuccin_directory_text "#{b:pane_current_path}"
      set -g @catppuccin_date_time_text "%H:%M"

      # fzf-url
      set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
      set -g @fzf-url-history-limit '2000'
    '';
  };
}
