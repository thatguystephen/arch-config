---@diagnostic disable: undefined-global -- dcli globals are provided by dcli runtime

-- Steph's Hyprland "base session" module.
--
-- Intent:
-- - Provide the core Hyprland compositor + Wayland plumbing + everyday tools.
-- - Keep shell layers (Noctalia/DMS/Ax-shell) in separate modules.
-- - EWW is *not* included here because you want it to run only in the "none" mode,
--   which is orchestrated by the shell switcher (and managed by the steph-eww module).
--
-- Notes:
-- - Some items below are repo packages, some are AUR (e.g. zen-browser-bin). dcli/yay will handle AUR.
-- - We install both xdg-desktop-portal-hyprland and xdg-desktop-portal-gtk to cover toolkits.
-- - This module syncs your Hyprland config into ~/.config/hypr.
--   IMPORTANT: ensure modules/steph-hyprland/dotfiles/hypr is a real directory in the repo,
--   not a symlink to your home directory, otherwise the repo won't be portable.

local packages = {
    -- Hyprland compositor + core utilities you use
    "hyprland",
    "hypridle",
    "hyprlock",
    "hyprpaper",

    -- Portals (Wayland desktop integration)
    "xdg-desktop-portal-hyprland",
    "xdg-desktop-portal-gtk",

    -- Clipboard + screenshots
    "wl-clipboard",
    "grim",
    "slurp",
    "swappy",

    -- Display / output management
    "nwg-displays",
    "ddcutil",

    -- Notifications + launcher (configs handled in steph-dunst/steph-rofi)
    "dunst",
    "rofi",

    -- Audio control UI (PipeWire itself can be managed elsewhere if you prefer)
    "pavucontrol",

    -- Common quality-of-life
    "brightnessctl",
    "playerctl",
    "network-manager-applet",
    "fastfetch",
    "kitty",

    -- Optional: you appear to use pyprland with Hyprland
    "pyprland",

    -- Your primary browser/editor (based on your package list)
    "zen-browser-bin",
    "neovim",
}

return {
    description = "Steph: Hyprland base compositor + core Wayland tools (no shell layer)",
    packages = packages,

    dotfiles_sync = true,
    dotfiles = {
        {
            source = "dotfiles/hypr",
            target = "~/.config/hypr",
        },
    },
}
