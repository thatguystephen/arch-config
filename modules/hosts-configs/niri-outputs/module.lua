---@diagnostic disable: undefined-global
local hostname = dcli.system.hostname()

local dotfiles = {}

if hostname == "spacethenomad" then
    -- spacethenomad uses Hyprland, Niri outputs not used
    dcli.log.info("niri-outputs: spacethenomad uses Hyprland, skipping Niri outputs")
elseif hostname == "steph-vm" then
    -- VM uses niri-desktop as fallback
    table.insert(dotfiles, {
        source = "dotfiles/niri/outputs-desktop.kdl",
        target = "~/.config/niri/outputs.kdl",
    })
else
    dcli.log.warn("niri-outputs: no outputs.kdl defined for host " .. hostname)
end

return {
    description = "Host-specific Niri outputs",
    dotfiles_sync = false,
    dotfiles = dotfiles,
}
