# zsh/.zshrc

# Interactive shell entry point: one small orchestrator, one file per concern.
#
# The load order lives here, in this explicit list -- not in file names -- the
# same way the Neovim config requires modules by name. Adding a file means
# adding it to the list; deleting one means removing the line.
#
# Cache dir and fpath must be set up before anything that autoloads.
#
# After the loop, local.zsh provides machine-specific overrides (unversioned),
# and zsh-syntax-highlighting is sourced last because it wraps existing ZLE
# widgets: anything defined after it may not be highlighted correctly.
#
# See: conf.d/syntax-highlighting.zsh

# Startup profiling (run: ZSH_PROF=1 zsh -i -c exit)
[[ -n $ZSH_PROF ]] && zmodload zsh/zprof

# Custom completions directory plus the autoloadable functions of this config.
fpath=(~/.zsh/completions $ZDOTDIR/functions $fpath)
autoload -Uz $ZDOTDIR/functions/*(N:t)

for _zsh_module in \
    env options history terminal vim-mode completion widgets fzf \
    autosuggestions zoxide direnv starship aliases git-widgets
do
    source "$ZDOTDIR/conf.d/$_zsh_module.zsh"
done
unset _zsh_module

# Machine-specific settings and secrets (not versioned).
[[ -r $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

# Must be sourced last because it wraps existing ZLE widgets.
source $ZDOTDIR/conf.d/syntax-highlighting.zsh

# Print the startup profile (see top of file)
[[ -n $ZSH_PROF ]] && zprof
