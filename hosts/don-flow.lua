return {
    host = "don-flow",
    description = "Packages specific to don-flow",
    import = {},

    enabled_modules = {
<<<<<<< HEAD
        "bdots-hypr",
=======
        "asus/asus",
>>>>>>> 8bb638d (stuff)
        "cli-tools/webapp-tool",
        "package-mods/main-apps",
        "dev/development",
<<<<<<< HEAD
        "zen-catppuccin",
        "bdots-niri",
        "hardware",
=======
        "cli-tools/cli-apps",
>>>>>>> 8bb638d (stuff)
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
        tool = nil,
        snapper_config = "root",
    },

    services = {
        enabled = {},
        disabled = {},
    },

    update_hooks = {
        pre_update = nil,
        post_update = nil,
        behavior = "ask",
    },

    default_apps = {
        scope = "system",
        browser = "firefox",
        text_editor = "helix",
        video_player = "mpv",
        audio_player = "mpv",
        image_viewer = "firefox",
        pdf_viewer = "firefox",
        mime_types = {},
    },

    editor = "helix",
    aur_helper = "yay",
}
