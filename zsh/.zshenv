# zsh/.zshenv

# Sourced by every zsh instance, interactive or not: scripts, `git commit`
# editors, cron wrappers. It must stay small and free of anything interactive,
# so paying its cost is always justified.
#
# Everything else is read from $ZDOTDIR by zsh itself (.zprofile, .zshrc,
# .zlogin). See: man zsh (FILES)

export ZDOTDIR="$HOME/dotfiles/zsh"
[[ -d $ZDOTDIR ]] || unset ZDOTDIR

# Jan Local API Server - Claude Code Config
export ANTHROPIC_BASE_URL='http://127.0.0.1:1337'
export ANTHROPIC_AUTH_TOKEN='jan'
export ANTHROPIC_DEFAULT_OPUS_MODEL='nvidia/nemotron-3-ultra-550b-a55b'
export ANTHROPIC_DEFAULT_SONNET_MODEL='nvidia/nemotron-3-super-120b-a12b'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='z-ai/glm-5.3'

# Programming note taking vault
export ARCANUM_DIR="$HOME/dev/arcanum"

# Rust toolchain: available to every shell, including non-interactive ones
# (e.g. building from scripts). See: conf.d/env.zsh for interactive PATHs.
export PATH="$HOME/.cargo/bin:$PATH"
