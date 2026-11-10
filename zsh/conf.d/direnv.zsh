# zsh/conf.d/direnv.zsh

# Load/unload per-directory .envrc files automatically.
#
# Hooked before the prompt init so the prompt reflects the loaded
# environment. Log output is silenced via DIRENV_LOG_FORMAT.
#
# See: https://direnv.net/
# See: conf.d/env.zsh

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
