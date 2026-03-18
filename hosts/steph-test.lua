return {
    host = "steph-vm",
    description = "Minimal VM test environment (reduced module set)",
    import = {},

    enabled_modules = {
        "base",
        "login-managers/sddm-astronaut-enable",
        "dotfiles",
    },

    packages = {},
    exclude = {},

    flatpak_scope = "user",
    auto_prune = false,
    module_processing = "sequential",
    strict_package_order = false,
    aur_helper = "yay",

    config_backups = {
        enabled = false,
    },

    system_backups = {
        enabled = false,
    },

    services = {
        enabled = {
            "NetworkManager",
            "sddm",
        },
        disabled = {},
    },
}
