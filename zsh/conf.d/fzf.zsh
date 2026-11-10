# zsh/conf.d/fzf.zsh

# fzf environment, sourcing of its key bindings and completion, and the
# custom directory picker binding.
#
# FZF_TMUX is disabled so popups render inline in the current pane instead
# of a tmux popup.
#
# See: https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
# See: conf.d/git-widgets.zsh (fzf usage inside git pickers)

# Disable tmux popup, force inline rendering in the current pane
export FZF_TMUX=0

export FZF_DEFAULT_OPTS="
--height 20%
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-n:down'
--bind 'ctrl-p:up'
--bind 'ctrl-f:preview-down'
--bind 'ctrl-b:preview-up'
--preview-window=wrap,hidden
"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# File preview
export FZF_CTRL_T_OPTS="--preview 'cat {}'"

# Load fzf key bindings and completion (skipped if fzf is not installed)
for _fzf_file in /usr/share/fzf/{key-bindings,completion}.zsh; do
    [[ -r $_fzf_file ]] && source "$_fzf_file"
done
unset _fzf_file

if (( $+widgets[fzf-cd-widget] )); then
    # Use Ctrl+F for fzf directory selection.
    bindkey -M viins '^F' fzf-cd-widget
    bindkey -M vicmd '^F' fzf-cd-widget

    # Disable fzf's default Alt+C binding.
    bindkey -M viins -r '^[c'
    bindkey -M vicmd -r '^[c'
fi
