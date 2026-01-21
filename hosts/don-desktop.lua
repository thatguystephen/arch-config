return {
    host = "don-desktop",
    description = "",
    import = {},

    enabled_modules = {
        "package-mods/main-apps",
        "gaming/gaming-packages",
        "gaming/controller-support",
        "cli-tools/cli-apps",
        "package-mods/content-creation",
        "dev/development",
        "bd-niri",
        "gaming/sunshine",
        "login-managers/dms-greeter",
        "cli-tools/webapp-tool",
        "dotfiles",
        "flapak",
        "hardware",
        "ricing/theming-apps",
        "package-mods/test-packages-2",
        "package-mods/test-packages",
        "system-packages-don-desktop"
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
        tool = "snapper",
        snapper_config = "root",
    },

    services = {
        enabled = {
            "NetworkManager",
            "NetworkManager-dispatcher",
            "NetworkManager-wait-online",
            "ananicy-cpp",
            "avahi-daemon",
            "bluetooth",
            "getty@",
            "greetd",
            "grub-btrfsd",
            "nvidia-hibernate",
            "nvidia-resume",
            "nvidia-suspend",
            "tailscaled",
            "ufw",
        },
        disabled = {},
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
        file_manager = "nemo",
        terminal = "kitty",
        video_player = "mpv",
        audio_player = "mpv",
        image_viewer = "chromium",
        pdf_viewer = "chromium",
        mime_types = {},
    },

    editor = "helix",
    aur_helper = "yay",
}
