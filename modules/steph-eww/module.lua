---@diagnostic disable: undefined-global -- dcli globals are provided by dcli runtime

-- Steph's EWW module
--
-- Purpose:
-- - Install EWW (ElKowar's Wacky Widgets)
-- - Sync Steph's EWW configuration into ~/.config/eww
--
-- Notes:
-- - You indicated EWW is part of the "none/default" session. Startup/orchestration
--   (when to run/stop EWW) should be handled by your Hyprland shell switcher logic,
--   not by this module.
-- - IMPORTANT: ensure modules/steph-eww/dotfiles/eww is a real directory in the repo,
--   not a symlink to your home directory.

local packages = {
    "eww",
}

return {
    description = "Steph: EWW widgets (config synced to ~/.config/eww)",
    packages = packages,

    dotfiles_sync = true,
    dotfiles = {
        {
            source = "dotfiles/eww",
            target = "~/.config/eww",
        },
    },
}
