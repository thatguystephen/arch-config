return {
    host = "spacethenomad",
    description = "Steph's primary desktop",
    sync_sudo = "true",
    import = {},

    enabled_modules = {
        "base",
        "hardware",
        "package-mods/main-apps",
        "gaming/gaming-packages",
        "gaming/controller-support",
        "gaming/sunshine",
        "cli-tools/cli-apps",
        "dev/development",
        "login-managers/sddm-astronaut-enable",
        "cli-tools/webapp-tool",
        "dotfiles",
        "flapak",
        "ricing/theming-apps",
        "system-packages-steph-desktop",
        "window-managers/steph-hyprland",
        "hosts-configs/noctalia-ui",
        "declared-packages",
    },

    packages = {},
    exclude = {},
    additional_packages = {},

    flatpak_scope = "user",
    auto_prune = true,
    module_processing = "sequential",
    strict_package_order = true,

    config_backups = {
        enabled = true,
        max_backups = 5,
    },

    system_backups = {
        enabled = true,
        backup_on_sync = true,
        backup_on_update = true,
        tool = "timeshift",
        snapper_config = "root",
    },

    services = {
        enabled = {
            "NetworkManager",
            "NetworkManager-dispatcher",
            "bluetooth",
            "docker",
            "mpd",
            "nvidia-hibernate",
            "nvidia-resume",
            "nvidia-suspend",
            "ollama",
            "sddm",
            "smb",
            "tailscaled",
            "ufw",
        },
        disabled = {
            "greetd",
        },
    },

    enabled_service_profiles = {},

    update_hooks = {
        pre_update = nil,
        post_update = nil,
        behavior = "ask",
    },

    default_apps = {
        scope = "system",
        browser = "zen",
        text_editor = "dev.zed.Zed",
        file_manager = "nautilus",
        terminal = "kitty",
        video_player = "mpv",
        audio_player = "mpv",
        image_viewer = "vimiv",
        pdf_viewer = "chromium",
        mime_types = {},
    },

    editor = "nvim",
    aur_helper = "yay",
}
