# zsh/conf.d/git-widgets.zsh

# fzf-based git pickers bound to Ctrl+G chords. Each widget inserts the
# selection into the current command line instead of running anything, so
# they can be combined with other commands
# (e.g. `git rebase <Ctrl+G Ctrl+G>`).
#
# See: functions/fzf-git-branches
# See: functions/fzf-git-files
# See: functions/fzf-git-commits
# See: aliases/gitrc

zle -N fzf-git-branches
zle -N fzf-git-files
zle -N fzf-git-commits

bindkey -M viins '^G^B' fzf-git-branches
bindkey -M vicmd '^G^B' fzf-git-branches
bindkey -M viins '^G^F' fzf-git-files
bindkey -M vicmd '^G^F' fzf-git-files
bindkey -M viins '^G^G' fzf-git-commits
bindkey -M vicmd '^G^G' fzf-git-commits
