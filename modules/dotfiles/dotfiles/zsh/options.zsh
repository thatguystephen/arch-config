# ------------------------------------------------------------------------------
# 3. ZSH OPTIONS & HISTORY
# ------------------------------------------------------------------------------

set -o vi
setopt extended_glob null_glob

HISTFILE=~/.zsh_history
HISTFILESIZE=100000
HISTSIZE=100000
HISTTIMEFORMAT="%F %T" # add timestamp to history
HISTDUPE=erase
SAVEHIST=1000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt hist_ignore_all_dups
setopt hist_save_no_dups

setopt LIST_PACKED		   # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.


fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit

# Command Editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'ec' edit-command-line

# Zstyle Completions
zstyle ':completion:*' file-sort date
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' auto-descriptions 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format '-- Completing %d --'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:paths' path-completion yes
zstyle ':completion:*:processes' command 'ps -afu $USER'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.config/zsh/cache
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' insert-unambiguous yes

zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' \
                --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:yellow:bold' \
                --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                --preview-label ' Preview ' --color 'preview-border:magenta,preview-label:magenta:bold'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter


# Completion tweaks
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Allow ctrl-S for history navigation
# [[ $- == *i* ]] && stty -ixon

