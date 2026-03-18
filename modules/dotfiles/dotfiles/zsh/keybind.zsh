## Keybindings

bindkey '^[[H' beginning-of-line
bindkey -M vicmd '^[[H' beginning-of-line
bindkey -M viins '^[[H' beginning-of-line

bindkey '^[[F' end-of-line
bindkey -M vicmd '^[[F' end-of-line
bindkey -M viins '^[[F' end-of-line

bindkey -s '^K' 'ls^M'
bindkey -s '^o' '_smooth_fzf^M'

# fix backspace and other stuff in vi-mode
bindkey -M viins '\e/' _vi_search_fix

bindkey "^[[3~" backward-delete-char
bindkey -M vicmd "^[[3~" backward-delete-char
bindkey -M viins "^[[3~" backward-delete-char

bindkey "^U" backward-kill-line
bindkey -M vicmd "^U" backward-kill-line
bindkey -M viins "^U" backward-kill-line

