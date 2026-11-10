# zsh/conf.d/terminal.zsh

# Terminal-level behavior: output flow control, window title, command-output
# markers for the multiplexer and pager settings.
#
# See: conf.d/vim-mode.zsh (ZLE_* variables and KEYTIMEOUT)
# See: conf.d/env.zsh    (PAGER/LESS defaults)

# Chars removed from a completion suffix when you keep typing past it
# ref: man zshparam
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;'

# Disable Ctrl+S freezing terminal output
# Ctrl+Q would otherwise be needed to resume it
# (only in ttys, so non-interactive scripts don't get a spurious stty error)
[[ -t 0 ]] && stty stop undef


# Window title

# Update the terminal title to the current directory before each prompt
# check `man zshmisc`
_set_win_title() {
    print -Pn "\e]0;%~\a"
}

precmd_functions+=(_set_win_title)


# Command output markers (OSC 133), consumed by the terminal multiplexer

# Mark the beginning of a command output
_osc133_preexec() {
    print -n "\e]133;C\e\\"
}

preexec_functions+=(_osc133_preexec)


# Man pages
export MANPAGER='less -i --incsearch --search-options=W -g -R --use-color -DER -DPY -DSWM -Ddg -Du+c'
export MANROFFOPT='-P -c'
