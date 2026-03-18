## PATH & ENV Var

path=(
	$path
	$HOME/.local/bin
	$HOME/.local/share/pipx/venvs/pyprland/bin/
	$HOME/scripts
	$HOME/.config/hypr/scripts
	$HOME/.config/rmpc
	$HOME/eww/target/release
)
typeset -U path
path=($^path(N-/))
export PATH

export FABRIC_ALIAS_PREFIX="fab_"
export PATH="$HOME/.cargo/bin:$PATH"
export GPG_TTY="${TTY:-$(tty)}"
export PATH="$HOME/.local/share/solana/install/releases/stable-6b04e8811190f74ebcd1c95c50fa724c11066dfe/solana-release/bin:$PATH"
export PATH="$HOME/development/flutter/bin:$PATH"
export PATH="$HOME/ncspot/target/debug:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export ANDROID_HOME=$HOME/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
#export PATH=$PATH:/opt/apache-spark/bin

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

export SPARK_HOME="/opt/spark"
export PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# Golang environment variables
export GOPATH=$HOME/go

# Update PATH to include GOPATH and GOROOT binaries
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Initialize Conda in zsh
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

export SUDO_PROMPT="passwd: "
export TERMINAL="kitty"
export VISUAL="nvim"
export EDITOR="nvim"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$XDG_DATA_HOME/flatpak/exports/share"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"

# UI Colors & Tool Options
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
export FZF_DEFAULT_OPTS='
--color=spinner:2,hl:6
--color=fg:7,header:3,info:4,pointer:4
--color=marker:2,fg+:7,prompt:6,hl+:6
'

# Less colors for manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

