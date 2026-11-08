# ~/.zshrc

# Startup profiling (run: ZSH_PROF=1 zsh -i -c exit)
[[ -n $ZSH_PROF ]] && zmodload zsh/zprof


# Environment

# Deduplicate PATH entries, even if .zshrc gets sourced more than once
typeset -U PATH

# pipx (appended) and pnpm (prepended)
export PNPM_HOME="$HOME/.local/share/pnpm"
path=("$PNPM_HOME" $path "$HOME/.local/bin")

# SDKMAN: put the installed candidates on PATH right away and only
# source the (slow) init script the first time `sdk` is actually called.
export SDKMAN_DIR="$HOME/.sdkman"
path=($SDKMAN_DIR/candidates/*/current/bin(N) $path)
[[ -d $SDKMAN_DIR/candidates/java/current ]] \
    && export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"

sdk() {
    unset -f sdk
    [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
}

# Custom completions directory
fpath=(~/.zsh/completions $fpath)

# Default applications
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"

# Locale (avoid LC_ALL: it overrides every other LC_* variable)
export LANG="en_US.UTF-8"

# Application-specific paths and settings
export BAT_THEME="ansi"
export OBSIDIAN_VAULT_PATH="$HOME/personal/documents/vault"

# Silence direnv's load/unload logs
export DIRENV_LOG_FORMAT=

# Make sure LS_COLORS is set (used by completion colors)
[[ -z $LS_COLORS ]] && (( $+commands[dircolors] )) && eval "$(dircolors -b)"

# Cache directory for zsh (completion dump and cache)
_zcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcache ]] || mkdir -p "$_zcache"


# Shell options

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NO_CASE_MATCH
setopt ALWAYS_TO_END


# Command timing

# Print elapsed time and resource usage for commands that take
# longer than REPORTTIME seconds, as if run with `time`.
# ref: man zshparam
REPORTTIME=10
TIMEFMT='%J  %*U user %*S system %P cpu %*E total'


# History

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# Trivial commands that are not worth keeping in the history.
HISTORY_IGNORE='(cd|cd ..|cd -|clear|c|q|exit|reload|reset|profile|ls|ls *|ll|la|lt|lta|d|sd|sc|ff|y|z|z *|nvr|nvc|nvs|nvn|nvim|vim|vi|less *|which *|command -v *|cp *|mv *|rm *|g|gs|gss|gd|gdc|gaf|ga|gc|gcm|gca|gcan|gp|gpf|ggp|gf|gfp|gpl|gplr|ggl|ggl *|gl|gb|gbc|gsw|gsws|gswt|gres|gst|gstu|gstp|gstf|gstl|gwip|gunwip|gwl|gwa|gwr|gwc|groot|croot)'


# Terminal behavior

# Chars removed from a completion suffix when you keep typing past it
# ref: man zshparam
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;'

# Disable Ctrl+S freezing terminal output
# Ctrl+Q would otherwise be needed to resume it
stty stop undef


# Window title

_set_win_title() {
    print -Pn "\e]0;%~\a"
}

# Update the terminal title before each prompt
# check `man zshmisc`
precmd_functions+=(_set_win_title)


# Command hooks

# Mark the beginning of a command output (OSC 133;C)
_osc133_preexec() {
    print -n "\e]133;C\e\\"
}
preexec_functions+=(_osc133_preexec)


# Vi mode

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


# Completion

# Rebuild the completion dump only if it is older than 24h,
# otherwise skip the security check with -C
_zcompdump="$_zcache/zcompdump"
autoload -Uz compinit
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi

# Needed for the menuselect keymap
zmodload zsh/complist

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:*:ls:*:*' list-dirs-first true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$_zcache/zcompcache"
zstyle ':completion:*' group-name ''

# Shift+Tab = go back one entry in the completion menu
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Esc inside the completion menu cancels it
cancel-completion() {
    zle .send-break
}

zle -N cancel-completion
bindkey -M menuselect '\e' cancel-completion


# fzf

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


# Autosuggestions

ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'

[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
    && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444444'

bindkey -M viins '^E' autosuggest-accept
bindkey -M viins '^Y' forward-word
bindkey -M viins '^O' autosuggest-execute
bindkey -M viins '^X^A' autosuggest-toggle


# zoxide

(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd z)"


# direnv

# Before the prompt init, so the prompt reflects the loaded environment
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"


# Starship

(( $+commands[starship] )) && eval "$(starship init zsh)"


# Aliases

# load aliases if exist
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/gitrc" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/gitrc"


# Profile management

# Reload the current shell configuration
# (exec avoids registering hooks twice)
reload() {
    exec zsh
}

# Open the zsh configuration in Neovim
profile() {
    nvim ~/.zshrc
}

# Open the definition of an alias, function or script in $EDITOR, on the
# right line. Looks in ~/.zshrc, aliasrc and gitrc.
# Usage: wvim <name>
wvim() {
    local name=$1 kind pattern hit

    [[ -z $name ]] && { echo "usage: wvim <name>" >&2; return 1; }

    kind=${$(whence -w -- $name)##*: }

    case $kind in
        alias)
            pattern="^[[:space:]]*(alias[[:space:]]+)?${name}=" ;;
        function)
            pattern="^[[:space:]]*(function[[:space:]]+)?${name}[[:space:]]*\\(\\)" ;;
        command)
            ${=EDITOR} "$(whence -p -- $name)"
            return ;;
        *)
            echo "\"$name\" not found" >&2
            return 1 ;;
    esac

    hit=$(grep -HnEm1 -- "$pattern" ~/.zshrc ~/.config/zsh/{aliasrc,gitrc} 2>/dev/null | head -1)

    [[ -z $hit ]] && { echo "definition of \"$name\" not found" >&2; return 1; }

    ${=EDITOR} "${hit%%:*}" "+${${hit#*:}%%:*}"
}
compdef wvim=which


# Command-line helpers

# Press Esc twice to prepend or remove "sudo " from the command line
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history

    if [[ $BUFFER == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
        (( CURSOR = CURSOR > 5 ? CURSOR - 5 : 0 ))
    else
        BUFFER="sudo $BUFFER"
        (( CURSOR += 5 ))
    fi
}

zle -N sudo-command-line
bindkey -M viins '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line


# Ctrl+Z: resume the last background job if the line is empty,
# otherwise stash the current line and clear the screen
fancy-ctrl-z() {
    if [[ -z $BUFFER ]]; then
        BUFFER="fg"
        zle accept-line -w
    else
        zle push-input -w
        zle clear-screen -w
    fi
}

zle -N fancy-ctrl-z
bindkey -M viins '^Z' fancy-ctrl-z
bindkey -M vicmd '^Z' fancy-ctrl-z

# Copy the last executed command to the clipboard
copy-last-command() {
    local cmd=${$(fc -ln -1)## }

    if (( $+commands[xclip] )); then
        print -rn -- "$cmd" | xclip -selection clipboard
    elif (( $+commands[wl-copy] )); then
        print -rn -- "$cmd" | wl-copy
    else
        zle -M "copy-last-command: xclip or wl-copy not found"
        return 1
    fi

    zle -M "Copied: $cmd"
}

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
open-vifm() {
    zle -I
    vifm </dev/tty
    zle reset-prompt
}

zle -N open-vifm
bindkey -M viins '^X^I' open-vifm
bindkey -M vicmd '^X^I' open-vifm


# List files without interrupting the current command line
list-files-inline() {
    local -a words
    local word="" dir="."

    words=("${(@z)LBUFFER}")
    [[ $LBUFFER != *[[:space:]] ]] && word="${(Q)words[-1]}"
    word="${word/#\~/$HOME}"

    if [[ -n $word ]]; then
        if [[ -d $word ]]; then
            dir="$word"
        elif [[ -d ${word:h} ]]; then
            dir="${word:h}"
        fi
    fi

    zle -I
    command ls --color=auto -- "$dir"
}

zle -N list-files-inline
bindkey -M viins '^X^U' list-files-inline
bindkey -M vicmd '^X^U' list-files-inline


# Git widgets (fzf)

# Insert the selection into the current command line instead of running
# anything, so they can be combined with other commands
# (e.g. `git rebase <Ctrl+G Ctrl+G>`).

# Pick one or more branches (excluding the current and the main ones)
fzf-git-branches() {
    local sel

    sel=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads 2>/dev/null |
        grep -vxE "$(git branch --show-current 2>/dev/null)|main|master|develop|development" |
        fzf --reverse --multi --select-1 | paste -sd' ' -)

    LBUFFER+="$sel"
    zle reset-prompt
}

# Pick one or more files from `git status`
fzf-git-files() {
    local sel

    sel=$(git -c color.status=always status --short 2>/dev/null |
        fzf --ansi --reverse --no-sort --multi | cut -c4- | paste -sd' ' -)

    LBUFFER+="$sel"
    zle reset-prompt
}

# Pick one or more commits (inserts the short hashes)
fzf-git-commits() {
    local sel

    sel=$(git log --color=always --oneline --decorate -50 2>/dev/null |
        fzf --ansi --reverse --no-sort --multi | cut -d' ' -f1 | paste -sd' ' -)

    LBUFFER+="$sel"
    zle reset-prompt
}

zle -N fzf-git-branches
zle -N fzf-git-files
zle -N fzf-git-commits

bindkey -M viins '^G^B' fzf-git-branches
bindkey -M vicmd '^G^B' fzf-git-branches
bindkey -M viins '^G^F' fzf-git-files
bindkey -M vicmd '^G^F' fzf-git-files
bindkey -M viins '^G^G' fzf-git-commits
bindkey -M vicmd '^G^G' fzf-git-commits


# Man pages

export MANPAGER='less -i --incsearch --search-options=W -g -R --use-color -DER -DPY -DSWM -Ddg -Du+c'
export MANROFFOPT='-P -c'


# Local overrides

# Machine-specific settings and secrets (not versioned)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local


# Syntax highlighting

# Must be sourced last because it wraps existing ZLE widgets.
# Anything defined after this point may not be highlighted correctly.
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
    && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Print the startup profile (see top of file)
[[ -n $ZSH_PROF ]] && zprof
