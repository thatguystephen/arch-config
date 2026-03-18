# Download Znap, if it's not there yet.
[[ -r ~/github/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/github/znap
source ~/github/znap/znap.zsh  # Start Znap

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
typeset -g -a ZSH_HIGHLIGHT_WIDGETS_SKIP
ZSH_HIGHLIGHT_WIDGETS_SKIP+=( _sudo_command_line )

# External Initializations
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(thefuck --alias fuck)"
eval "$(thefuck --alias)"

# NVM Setup
source /usr/share/nvm/init-nvm.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

znap source jeffreytse/zsh-vi-mode

function zvm_after_init() {
  # Your existing keybinds
  bindkey '^[[H' beginning-of-line
  bindkey -M vicmd '^[[H' beginning-of-line
  bindkey -M viins '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line
  bindkey -M vicmd '^[[F' end-of-line
  bindkey -M viins '^[[F' end-of-line
  bindkey -s '^K' 'ls^M'
  bindkey -s '^o' '_smooth_fzf^M'
  bindkey "^U" backward-kill-line
  bindkey -M vicmd "^U" backward-kill-line
  bindkey -M viins "^U" backward-kill-line
  bindkey -M emacs '^B' _sudo_command_line
  bindkey -M vicmd '^B' _sudo_command_line
  bindkey -M viins '^B' _sudo_command_line

  # Restore fzf Ctrl+R history search
  bindkey '^R' fzf-history-widget
}

# Theme & Highlighting (Must be at the very bottom)
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

znap source zsh-users/zsh-completions

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets pattern cursor )
znap source zsh-users/zsh-syntax-highlighting

