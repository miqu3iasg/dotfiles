# zsh/conf.d/autosuggestions.zsh

# Fish-like fast syntax-based suggestions as you type.
#
# ZSH_AUTOSUGGEST_HISTORY_IGNORE skips suggesting multi-line commands:
# pasting a heredoc at the prompt creates suggestions that accept partial
# commands and are dangerous to execute.
#
# Must load before zsh-syntax-highlighting (see .zshrc) so both can wrap
# widgets.
#
# See: https://github.com/zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'

[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
    && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444444'

bindkey -M viins '^E' autosuggest-accept
bindkey -M viins '^Y' forward-word
bindkey -M viins '^O' autosuggest-execute
bindkey -M viins '^X^A' autosuggest-toggle
