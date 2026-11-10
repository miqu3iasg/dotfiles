# zsh/conf.d/completion.zsh

# Completion system bootstrap and settings. The cache dump is rebuilt (with
# the compaudit security scan) only when older than 24h; `-C` skips both
# while the dump is fresh, so most shells start fast.
#
# compinit only rewrites the dump when it finds new functions; without
# changes on disk the mtime goes stale and the full check would run on every
# shell start, forever -- hence the touch.
#
# See: man zshcompsys
# See: .zshrc (fpath: the custom completions dir is added there)

# Cache directory for zsh (completion dump and cache)
_zcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcache ]] || mkdir -p "$_zcache"

# Rebuild the completion dump only if it is older than 24h,
# otherwise skip the security check with -C
_zcompdump="$_zcache/zcompdump"
autoload -Uz compinit
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"
    touch "$_zcompdump"
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

# Tab-completion for the wvim helper
# See: functions/wvim
compdef wvim=which
