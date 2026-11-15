# zsh/.zshenv

# Sourced by every zsh instance, interactive or not: scripts, `git commit`
# editors, cron wrappers. It must stay small and free of anything interactive,
# so paying its cost is always justified.
#
# Everything else is read from $ZDOTDIR by zsh itself (.zprofile, .zshrc,
# .zlogin). See: man zsh (FILES)

export ZDOTDIR="$HOME/dotfiles/zsh"
[[ -d $ZDOTDIR ]] || unset ZDOTDIR

# Programming note taking vault
export ARCANUM_DIR="$HOME/dev/arcanum"

# Rust toolchain: available to every shell, including non-interactive ones
# (e.g. building from scripts). See: conf.d/env.zsh for interactive PATHs.
export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
