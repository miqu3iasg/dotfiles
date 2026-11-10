# zsh/conf.d/history.zsh

# History size, storage and filtering.
#
# HISTORY_IGNORE keeps trivial navigation and view commands out of the file,
# including the many single-letter aliases of aliases/gitrc.
#
# See: man zshoptions (HIST_* setopts)
# See: aliases/aliasrc, aliases/gitrc

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
setopt EXTENDED_HISTORY

# Trivial commands that are not worth keeping in the history.
HISTORY_IGNORE='(cd|cd ..|cd -|clear|c|q|exit|reload|reset|profile|ls|ls *|ll|la|lt|lta|d|sd|sc|ff|y|z|z *|nvr|nvc|nvs|nvn|nvim|vim|vi|less *|which *|command -v *|cp *|mv *|rm *|g|gs|gss|gd|gdc|gaf|ga|gc|gcm|gca|gcan|gp|gpf|ggp|gf|gfp|gpl|gplr|ggl|ggl *|gl|gb|gbc|gsw|gsws|gswt|gres|gst|gstu|gstp|gstf|gstl|gwip|gunwip|gwl|gwa|gwr|gwc|groot|croot)'
