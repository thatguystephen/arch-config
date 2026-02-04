---@diagnostic disable: undefined-global -- dcli globals are provided by dcli runtime

-- Steph Rofi module
--
-- Purpose:
-- - Install Rofi (launcher) and any runtime tools it relies on in your setup.
-- - Sync your Rofi configuration into ~/.config/rofi (Option A: repo is source of truth).
--
-- Notes:
-- - Ensure `modules/steph-rofi/dotfiles/rofi` is a real directory committed to the repo
--   (not a symlink to your home directory), otherwise portability is compromised.

local packages = {
    "rofi",
    -- Common dependency for many rofi scripts/themes; harmless if not used everywhere
    "bash",
}

return {
    description = "Steph: Rofi launcher + config",
    packages = packages,

    dotfiles_sync = true,
    dotfiles = {
        {
            source = "dotfiles/rofi",
            target = "~/.config/rofi",
        },
    },
}
