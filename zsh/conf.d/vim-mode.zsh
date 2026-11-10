# zsh/conf.d/vim-mode.zsh

# Vi editing mode: keymap bindings, word motion and history navigation.
# Widgets backed by autoloadable files in ../functions/ are registered in
# conf.d/widgets.zsh; this file only handles the built-in ZLE widgets.
#
# See: man zshzle (USER-DEFINED WIDGETS, KEYMAPS)
# See: conf.d/widgets.zsh

bindkey -v

KEYTIMEOUT=10

bindkey -M vicmd 'u' undo
bindkey -M vicmd 'U' redo

# Y yanks to end of line
bindkey -M vicmd 'Y' vi-yank-eol

# Backspace deletes past the point where insert mode started
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^[[3~' delete-char

# Insert last argument of the previous command
bindkey -M viins '^[.' insert-last-word

# Clear screen
bindkey -M viins '^X^S' clear-screen
bindkey -M vicmd '^X^S' clear-screen

# Delete from start of line to cursor
bindkey -M viins '^U' backward-kill-line


# Word movement and deletion

# Treat hyphens, slashes, and similar characters as word boundaries
# for word-motion commands
autoload -Uz select-word-style
select-word-style bash

autoload -Uz backward-kill-word-match
zle -N backward-kill-space-word backward-kill-word-match
zstyle ':zle:backward-kill-space-word' word-style space

# Ctrl+W stops at `/`, `-` and similar (word-style bash);
# Alt+Backspace and Ctrl+Backspace delete up to the previous space
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^[^?' backward-kill-space-word
bindkey -M viins '^H' backward-kill-space-word


# History navigation

# Search history using the current command-line prefix
# up-line-or-search / down-line-or-search match what is already typed,
# unlike up-line-or-history / down-line-or-history
autoload -Uz up-line-or-search
autoload -Uz down-line-or-search
bindkey -M viins '^P' up-line-or-search
bindkey -M viins '^N' down-line-or-search
bindkey -M vicmd '^P' up-line-or-search
bindkey -M vicmd '^N' down-line-or-search
