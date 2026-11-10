# zsh/conf.d/widgets.zsh

# Registration of the autoloadable ZLE widgets in ../functions/: one zle -N
# per function plus its key bindings. The function bodies are lazy-loaded
# from fpath on first use.
#
# See: functions/
# See: conf.d/vim-mode.zsh (built-in widgets and keymaps)

# Press Esc twice to prepend or remove "sudo " from the command line
zle -N sudo-command-line
bindkey -M viins '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line

# Ctrl+Z: resume the last background job if the line is empty,
# otherwise stash the current line and clear the screen
zle -N fancy-ctrl-z
bindkey -M viins '^Z' fancy-ctrl-z
bindkey -M vicmd '^Z' fancy-ctrl-z

# Copy the last executed command to the clipboard
zle -N copy-last-command
bindkey -M viins '^X^Y' copy-last-command
bindkey -M vicmd '^X^Y' copy-last-command

# Edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line
bindkey -M vicmd '^V' edit-command-line

# Open vifm without touching the history
zle -N open-vifm
bindkey -M viins '^X^I' open-vifm
bindkey -M vicmd '^X^I' open-vifm

# List files without interrupting the current command line
zle -N list-files-inline
bindkey -M viins '^X^U' list-files-inline
bindkey -M vicmd '^X^U' list-files-inline
