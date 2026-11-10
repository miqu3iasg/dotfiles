# zsh/conf.d/vim-mode.zsh

# Vi editing mode: keymap setup, motions, history navigation and search.
#
# The guiding rule is parity: keys that mean the same thing in vi and
# readline (word motions, history prefix search, clear screen) behave the
# same in both keymaps, so switching modes never rebinds muscle memory.
# Purely vi behaviors (operator-pending `d`/`c`/`y` with motions, `f`/`t`
# finds, marks, `.` repeat) are left as zsh defaults and not listed here.
#
# Widgets backed by autoloadable files in ../functions/ are registered in
# conf.d/widgets.zsh; fzf and autosuggestions own their own keys
# (fzf.zsh: ^R/^T/^F, autosuggestions.zsh: ^E/^O/^Y/^X^A).
#
# See: man zshzle (USER-DEFINED WIDGETS, KEYMAPS)
# See: conf.d/widgets.zsh
# See: conf.d/terminal.zsh (stty flow control: makes ^S usable)

bindkey -v

# Delay in 1/100s of a second before a lone Esc (or an Esc chord) resolves,
# so multi-key chords like Esc Esc and ^[. still work in insert mode.
KEYTIMEOUT=10


# Normal mode

bindkey -M vicmd 'u' undo
bindkey -M vicmd 'U' redo

# Y yanks to end of line (as in vim), instead of the zsh default of
# vi-yank-whole-line, which already exists as `yy`.
bindkey -M vicmd 'Y' vi-yank-eol

# History prefix search in normal mode, parity with insert mode.
bindkey -M vicmd '^P' up-line-or-search
bindkey -M vicmd '^N' down-line-or-search


# Insert mode

# Backspace deletes past the point where insert mode started (readline
# behavior); the zsh default of vi-backward-char would stop there.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^[[3~' delete-char

# Insert last argument of the previous command (readline muscle memory).
bindkey -M viins '^[.' insert-last-word

# Delete from start of line to cursor (readline ^U), instead of the zsh
# default of vi-kill-line, which kills the whole line.
bindkey -M viins '^U' backward-kill-line


# Word motion and deletion

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

# Emacs-style word motions in insert mode, using the same word style:
# Alt+B/Alt+F move, Alt+D kills forward (pairs with ^W killing backward).
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[f' forward-word
bindkey -M viins '^[d' kill-word


# History navigation and search

# Prefix search using the current command-line: ^P/^N match what is already
# typed, unlike up-line-or-history/down-line-or-history. Arrow keys keep the
# zsh defaults (up/down-line-or-history) and `k`/`j` walk history in normal
# mode, as in vim.
autoload -Uz up-line-or-search
autoload -Uz down-line-or-search
bindkey -M viins '^P' up-line-or-search
bindkey -M viins '^N' down-line-or-search

# Forward incremental search in insert mode (backward incremental search is
# taken by fzf's ^R). Requires stty stop undef, done in terminal.zsh.
bindkey -M viins '^S' history-incremental-pattern-search-forward

# Clear screen: ^L is the zsh default in both keymaps and is kept as the
# single binding (an earlier custom ^X^S duplicate was removed).

# Selection: `v` and `V` in normal mode enter zsh's visual mode (selection
# over the command line), available since zsh 5.9. Kept unbound so the
# defaults apply.
