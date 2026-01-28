return {
    host = "don-vm",
    description = "Minimal VM testing environment",
    import = {},

    enabled_modules = {
        "bd-niri",
        "dotfiles",
        "cli-tools/cachy-repo",
        "cli-tools/chaotic-aur",
    },

    packages = {},
    exclude = {},

    flatpak_scope = "user",
    auto_prune = false,
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
