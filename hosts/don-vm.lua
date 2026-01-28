return {
    host = "don-vm",
    description = "Minimal VM testing environment",
    import = {},

    enabled_modules = {
        "cli-tools/cachyos-repo",
        "cli-tools/chaotic-aur",
        "login-managers/sddm-enable",
        "bd-niri",
        "dotfiles",
    },

    packages = {},
    exclude = {},

    flatpak_scope = "user",
    auto_prune = false,
    module_processing = "sequential",
    strict_package_order = true,
    aur_helper = "yay",

    config_backups = {
        enabled = false,
    },

    system_backups = {
        enabled = false,
    },

    services = {
        enabled = {},
        disabled = {},
    },
}
