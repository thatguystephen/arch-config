-- Packages installed on spacethenomad (steph's desktop)
-- Generated from actual installed package list, excluding packages managed by other modules
-- Last synced: 2026-03-17
--
-- NOTE: The CachyOS install template is preserved in module.lua.cachyos-template
-- if you want to experiment with a CachyOS-based setup in the future.

local packages = {
    -- Audio
    "alsa-plugins",
    "alsa-utils",
    "pipewire",
    "pipewire-alsa",
    "pipewire-jack",
    "pipewire-pulse",
    "wireplumber",
    "gst-plugin-pipewire",
    "pamixer",
    "pavucontrol",
    "libpulse",

    -- Bluetooth
    "bluez",
    "bluez-utils",
    "bluetuith",
    "overskride",
    "gnome-bluetooth-3.0",

    -- Shell & Terminal Tools
    "zsh",
    "zsh-autocomplete",
    "zsh-autosuggestions",
    "zsh-syntax-highlighting",
    "zsh-theme-powerlevel10k-git",
    "bash-completion",
    "bat",
    "bat-extras",
    "fzf",
    "jq",
    "nano",
    "stow",
    "thefuck",
    "trash-cli",
    "tree",
    "vim",
    "wget",
    "yt-dlp",
    "inxi",
    "multitail",
    "mlocate-git",

    -- Hyprland & Wayland Stack
    "hyprland",
    "hypridle",
    "hyprlock",
    "hyprpaper",
    "hyprpicker",
    "hyprshot",
    "hyprshutdown",
    "hyprsunset",
    "uwsm",
    "xdg-desktop-portal-hyprland",
    "xdg-desktop-portal-gtk",
    "xdg-desktop-portal-kde",
    "xdg-terminal-exec-git",
    "xdg-utils",
    "wlr-randr",
    "nwg-displays",
    "grim",
    "slurp",
    "swappy",
    "cliphist",

    -- Shell UI / Widgets
    "noctalia-shell",
    "dms-shell-git",
    "aylurs-gtk-shell-git",
    "libastal-gjs-git",
    "libastal-meta",
    "gjs",
    "blueprint-compiler",
    "dart-sass",
    "gtk-layer-shell",
    "gtk-engine-murrine",
    "matugen-bin",
    "rofi",
    "rofi-calc",
    "dunst",
    "wofi",

    -- App Launcher / Quickshell deps
    "awww-git",
    "gray-git",
    "fabric-cli-git",
    "python-fabric-git",
    "resvg",
    "socat",

    -- Theming
    "adw-gtk-theme",
    "breeze-gtk",
    "kanagawa-gtk-theme-git",
    "kanagawa-icon-theme-git",
    "kvantum-git",
    "kvantum-qt5",
    "qt5ct",
    "qt5-wayland",
    "qt6ct",
    "qt6-wayland",
    "qt6-virtualkeyboard",
    "lutgen-studio-bin",

    -- Fonts
    "noto-fonts-emoji",
    "otf-geist-mono-nerd",
    "ttf-iosevka",
    "ttf-iosevka-nerd",
    "ttf-iosevkaterm-nerd",
    "ttf-iosevkatermslab-nerd",
    "ttf-jetbrains-mono-nerd",
    "ttf-liberation",
    "ttf-nerd-fonts-symbols",
    "ttf-nerd-fonts-symbols-mono",
    "ttf-victor-mono-nerd",

    -- NVIDIA
    "libva-nvidia-driver",
    "nvidia-container-toolkit",

    -- Network
    "network-manager-applet",
    "iwd",
    "wireless_tools",
    "samba",
    "ntfs-3g",
    "gvfs",
    "gvfs-smb",

    -- System / Boot
    "grub",
    "efibootmgr",
    "dkms",
    "rtw88-dkms-git",
    "zram-generator",
    "plymouth",
    "plymouth-theme-alienware-git",
    "plymouth-theme-cross-hud-git",
    "plymouth-theme-splash-git",
    "reflector",
    "smartmontools",
    "ufw",
    "sddm",
    "timeshift",
    "polkit-kde-agent",
    "polkit-qt5",
    "power-profiles-daemon",

    -- Display / Input
    "brightnessctl",
    "ddcutil",
    "xorg-server",
    "xorg-xinit",
    "xorg-xrandr",
    "xdotool",
    "xclip",
    "xfce4-settings",

    -- File Management
    "dolphin",
    "thunar-volman",
    "file-roller",
    "udiskie",

    -- Media & Graphics
    "mpd",
    "mpd-mpris",
    "mpdris2",
    "mpc",
    "rmpc",
    "playerctl",
    "imagemagick",
    "gimp",
    "vimiv",
    "vlc",
    "vlc-plugin-ffmpeg",

    -- Music
    "spotify",
    "spicetify-cli",
    "picard",
    "cava",
    "btop",
    "bottom",
    "nvtop",

    -- Communication / Productivity
    "protonmail-bridge",
    "thunderbird",
    "libreoffice-fresh",
    "keepassxc",
    "pass",
    "putty",

    -- Gaming / Emulation
    "lutris",
    "wine",
    "goverlay",

    -- Docker / Containers
    "docker",
    "docker-compose",

    -- Python ecosystem
    "python-pywalfox",
    "python-pywayland",
    "python-pipx",
    "python-pip",
    "python-spotipy",
    "python-colorthief",
    "python-haishoku",
    "python-cairo",
    "python-toml",
    "python-watchdog",
    "python-joblib",
    "python-levenshtein",
    "python-ijson",
    "python-fissix",
    "python-future",
    "python-flake8",
    "python-pyusb",
    "python38",

    -- Node / JS
    "npm",
    "pnpm",
    "nvm",

    -- Rust / Build
    "rustup",
    "luarocks",

    -- Misc CLI
    "7zip",
    "acpi",
    "archlinux-xdg-menu",
    "aur-check-updates-bin",
    "cpio",
    "cyme",
    "ex-vi-compat",
    "gobject-introspection",
    "gnome-keyring",
    "imagemagick",
    "jpegoptim",
    "log4c",
    "optipng",
    "opusfile",
    "sdl12-compat",
    "taglib1",
    "libfishsound",
    "libheif",
    "libmad",
    "liboggz",
    "libcurl-gnutls",
    "webp-pixbuf-loader",
    "tesseract",
    "tesseract-data-eng",
    "tesseract-data-spa",

    -- Misc GUI
    "octopi",
    "neofetch",
    "smassh-bin",
    "monique",
    "localsend",
}

return {
    description = "Packages installed on spacethenomad (steph's desktop) - synced from actual system",
    hook_behavior = "ask",
    packages = packages,
}
