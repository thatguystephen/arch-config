return {
    host = "steph-vm",
    description = "Minimal VM testing environment",
    import = {},

    enabled_modules = {
        "base",
        "cli-tools/cachyos-repo",
        "cli-tools/chaotic-aur",
        "login-managers/sddm-astronaut-enable",
        "dotfiles",
        "declared-packages",
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
