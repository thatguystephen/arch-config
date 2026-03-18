# Source modules in order
while read -r file; do
  [[ -f "$ZDOTDIR/$file.zsh" ]] && source "$ZDOTDIR/$file.zsh"
done <<EOF
env
options
aliases
keybind
utility
plugins
EOF

# ------------------------------------------------------------------------------
# 1. POWERLEVEL10K INSTANT PROMPT
# ------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Kitty integration (if running in kitty)
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi
