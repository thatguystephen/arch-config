local packages = {
    -- Terminal
    "kitty",
    "fastfetch",
    -- File Management
    "xplr",
    "felix-rs",
    "nemo",
    -- Comms
    "telegram-desktop",
    "vesktop",
    "discord",
    -- Browser
    "zen-browser-bin",
    -- Notes
    "obsidian",
    -- Editor
    "zed",
}

return {
    description = "Main applications and utilities for daily use",
    conflicts = {},
    packages = packages,
}
