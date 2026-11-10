# zsh/conf.d/env.zsh

# Interactive-session environment: PATH layout, editor and locale defaults,
# and application-specific knobs.
#
# Anything needed by non-interactive shells (API endpoints, toolchains used
# by scripts) lives in .zshenv instead; anything about how the prompt and the
# terminal behave lives in the other modules of this directory.
#
# See: .zshenv
# See: conf.d/direnv.zsh (consumes DIRENV_LOG_FORMAT)
# See: conf.d/completion.zsh (consumes LS_COLORS)

# Deduplicate PATH entries, even if .zshrc gets sourced more than once.
# The U attribute must be on the `path` array (assignments to it go
# through here too); the tied scalar PATH alone is not enough.
typeset -U path PATH

# pipx provides ~/.local/bin via .zprofile; pnpm (prepended) here
export PNPM_HOME="$HOME/.local/share/pnpm"
path=("$PNPM_HOME" $path)

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
