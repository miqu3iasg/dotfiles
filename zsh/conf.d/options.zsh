# zsh/conf.d/options.zsh

# Global shell options and command timing. Kept apart from bindings and
# plugins so a glance at this file describes the shell's general behavior.
#
# See: man zshoptions
# See: conf.d/terminal.zsh (stty handling)
# See: conf.d/vim-mode.zsh (ZLE behavior and KEYTIMEOUT)

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NO_CASE_MATCH
setopt ALWAYS_TO_END


# Command timing

# Print elapsed time and resource usage for commands that take
# longer than REPORTTIME seconds, as if run with `time`.
# ref: man zshparam
REPORTTIME=10
TIMEFMT='%J  %*U user %*S system %P cpu %*E total'
