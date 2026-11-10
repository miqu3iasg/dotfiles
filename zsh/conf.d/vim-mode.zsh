# zsh/conf.d/vim-mode.zsh

# Vi editing mode: motions, history and search.
#
# Keys that mean the same thing in vi and readline behave the same in both
# keymaps. Widgets from functions/ are registered in conf.d/widgets.zsh;
# fzf and autosuggestions own their own keys. Inside tmux,
# vim-tmux-navigator takes some chords for pane navigation, so bindings
# that must work there use alternatives.
#
# See: man zshzle
# See: conf.d/widgets.zsh
# See: ../tmux/tmux.conf

bindkey -v

KEYTIMEOUT=10	# Esc chord delay, in 1/100s


# Normal mode

bindkey -M vicmd 'u' undo
bindkey -M vicmd 'U' redo
bindkey -M vicmd 'Y' vi-yank-eol	# yank to end of line, as in vim
bindkey -M vicmd '^P' up-line-or-search
bindkey -M vicmd '^N' down-line-or-search


# Insert mode

bindkey -M viins '^?' backward-delete-char	# cross the insert-start mark, readline-style
bindkey -M viins '^[[3~' delete-char
bindkey -M viins '^[.' insert-last-word
bindkey -M viins '^U' backward-kill-line	# readline ^U, not the whole line

bindkey -M viins '^X^S' clear-screen	# ^L goes to tmux pane navigation


# Word motion and deletion

# `/`, `-` and friends split words
autoload -Uz select-word-style
select-word-style bash

autoload -Uz backward-kill-word-match
zle -N backward-kill-space-word backward-kill-word-match
zstyle ':zle:backward-kill-space-word' word-style space

bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^[^?' backward-kill-space-word	# tmux owns ^H
bindkey -M viins '^H' backward-kill-space-word
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[f' forward-word	# Alt+F; ^F is fzf's directory picker
bindkey -M viins '^[d' kill-word


# History

# ^P/^N search by prefix; arrows and k/j keep the zsh defaults
autoload -Uz up-line-or-search
autoload -Uz down-line-or-search
bindkey -M viins '^P' up-line-or-search
bindkey -M viins '^N' down-line-or-search

bindkey -M viins '^S' history-incremental-pattern-search-forward	# needs stty stop undef
