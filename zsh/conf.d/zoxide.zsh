# zsh/conf.d/zoxide.zsh

# Smarter `cd` that learns your habits. Installed as the `z` command;
# plain `cd` keeps its standard behavior.
#
# See: https://github.com/ajeetdsouza/zoxide

(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd z)"
