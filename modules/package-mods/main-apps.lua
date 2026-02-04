local packages = {
    -- Terminal
    "kitty",
    "fastfetch",
    -- File Management
    "nautilus",
    "thunar",
    -- Comms
    "vesktop",
    "discord",
    -- Browsers
    "zen-browser-bin",
    "helium-browser-bin",
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
