local packages = {
    -- Terminal
    "kitty",
    "fastfetch",
    -- File Management
    "nautilus",
    "thunar",
    -- Comms
    "vesktop-bin",
    -- Browsers
    "zen-browser-bin",
    "helium-browser-bin",
    "librewolf-bin",
    -- Notes
    "obsidian",
    -- Editor
    "zed",
    -- Additional daily apps
    "localsend",
    "keepassxc",
    "thunderbird",
}

return {
    description = "Main applications and utilities for daily use",
    conflicts = {},
    packages = packages,
}
