# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
# Ripgrep Check
if command -v rg &> /dev/null; then
    alias grep='rg'
else
    alias grep="/usr/bin/grep $GREP_OPTIONS"
fi
unset GREP_OPTIONS

# Navigation
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../..'
alias .....='cd ../../../..'
alias cdi='zi'
alias bd='cd "$OLDPWD"'

# File Modification & System
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias pacman='sudo pacman'
alias syu='pacman -Syu'
alias u="yay -Syu"
alias q="yay -Q"
alias i="pkg-aur-install"
alias rp="pkg-remove"
alias rmd='/bin/rm --recursive --force --verbose '
alias da='date "+%Y-%m-%d %A %T %Z"'
alias mirrors="sudo reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist"
alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# Neovim
command_exists() {
  command -v $1 >/dev/null 2>&1
}

if command_exists nvim; then
  alias v='nvim'
  alias vf='nvim $(fzf)'
  alias svi='sudo nvim'
  alias vis='nvim "+set si"'
fi

alias ezrc='cd ~/.config/zsh/ && nvim .'
alias sr='source ~/.config/zsh/.zshrc'
alias ehypr='cd ~/.config/hypr/ && nvim .'

# Directory Listing
alias la='ls -Alh'
alias ls='ls -aFh --color=always'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh | less'
alias lw='ls -xAh'
alias ll='ls -Fls'
alias labc='ls -lap'
alias las='ls -A'
alias ldir="ls -ld */"
alias lf="ls -lp | grep -v '^d'"

# Chmod
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search & Info
alias h="history | grep "
alias p="ps aux | grep "
alias f="find . | grep "
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mti='df -hT'

# Misc
alias kssh="kitty +kitten ssh"
alias cat="bat --theme base16"
alias gearlever='flatpak run it.mijorus.gearlever'
alias pbpaste='wl-paste'
alias jctl="journalctl -p 3 -xb"

# Git
gitpush() {
    git add .
    git commit -m "$*"
    git pull
    git push
}
gitupdate() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github
    ssh -T git@github.com
}
alias gp=gitpush
alias gu=gitupdate

