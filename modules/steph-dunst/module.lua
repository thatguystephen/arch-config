---@diagnostic disable: undefined-global -- dcli globals are provided by dcli runtime

-- Steph's Dunst module
--
-- Purpose:
-- - Install dunst (if not already present via other modules)
-- - Sync your Dunst configuration into ~/.config/dunst
--
-- Notes:
-- - You said you want dunst managed by your Hyprland config (exec-once), so this module
--   does NOT attempt to manage any systemd user service for dunst.
-- - For portability, ensure `dotfiles/dunst` is a real directory in this repo (not a symlink).

return {
    description = "Steph: Dunst notifications (config sync; started by Hyprland)",
    packages = {
        "dunst",
    },

    dotfiles_sync = true,
    dotfiles = {
        {
            source = "dotfiles/dunst",
            target = "~/.config/dunst",
        },
    },
}
