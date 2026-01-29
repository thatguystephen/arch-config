---@diagnostic disable: undefined-global

local hostname = dcli.system.hostname()
local desktop = (dcli.env.get("XDG_CURRENT_DESKTOP") or dcli.env.get("DESKTOP_SESSION") or ""):lower()

local desktop_map = {
    hypr = "hyprland",
    hyprland = "hyprland",
    ["hyprland-x11"] = "hyprland",
    ["hyprland-wayland"] = "hyprland",
    niri = "niri",
    mango = "mango",
    kde = "kde",
    plasma = "kde",
    plasmawayland = "kde",
    cosmic = "cosmic",
    ["cosmic-xero"] = "cosmic",
}

local host_defaults = {
    ["don-desktop"] = "niri",
    ["don-flow"] = "niri",
    ["don-vm"] = "niri",
}

local variant = desktop_map[desktop] or host_defaults[hostname] or "niri"

local dotfiles = {
    {
        source = "dotfiles/noctalia/" .. variant,
        target = "~/.config/noctalia",
    },
}

if variant == "niri" and desktop_map[desktop] == nil and host_defaults[hostname] == nil then
    dcli.log.warn("noctalia-ui: unknown desktop, defaulting to niri variant")
end

return {
    description = "Host/desktop-aware Noctalia UI configuration",
    dotfiles_sync = false,
    dotfiles = dotfiles,
}
