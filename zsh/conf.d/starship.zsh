# zsh/conf.d/starship.zsh

# Cross-shell prompt, configured in ../starship.toml (same repository).
# Network/safety indicators and git segments are defined there.
#
# See: ../starship.toml
# See: ../starship (dotfiles module with the tested timings)

(( $+commands[starship] )) && eval "$(starship init zsh)"
