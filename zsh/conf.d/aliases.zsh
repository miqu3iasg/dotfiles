# zsh/conf.d/aliases.zsh

# Loads the alias groups from aliases/: general replacements (aliasrc) and
# git (gitrc). Sourced after the plugins so alias lookups see the full
# command palette.
#
# See: aliases/aliasrc
# See: aliases/gitrc
# See: functions/wvim (jump to the definition of an alias)

# load aliases if exist
[[ -f $ZDOTDIR/aliases/aliasrc ]] && . "$ZDOTDIR/aliases/aliasrc"
[[ -f $ZDOTDIR/aliases/gitrc ]] && . "$ZDOTDIR/aliases/gitrc"
