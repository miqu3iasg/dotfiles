# zsh/conf.d/syntax-highlighting.zsh

# Fish-like highlighting of the command line as you type.
#
# Sourced from .zshrc, outside the conf.d loop, as the very last thing the
# shell loads: it wraps existing ZLE widgets, so anything defined after it
# may not be highlighted correctly.
#
# See: https://github.com/zsh-users/zsh-syntax-highlighting

[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
    && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
