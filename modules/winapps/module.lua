-- WinApps - Run Windows applications seamlessly on Linux
-- Requires Docker/Podman and KVM virtualization support

local packages = {}
local services = { enabled = {}, disabled = {} }

-- System requirements check
local memory_mb = dcli.system.memory_total_mb()
local cpu_cores = dcli.system.cpu_cores()
local cpu_vendor = dcli.hardware.cpu_vendor()

dcli.log.info("=== WinApps System Check ===")
dcli.log.info(string.format("RAM: %d GB", math.floor(memory_mb / 1024)))
dcli.log.info(string.format("CPU: %s (%d cores)", cpu_vendor, cpu_cores))

-- RAM recommendation
if memory_mb < 8000 then
    dcli.log.warn("WinApps recommends 8GB+ total RAM for optimal performance")
    dcli.log.warn(string.format("Detected: %d GB - Windows VM may run slowly", math.floor(memory_mb / 1024)))
elseif memory_mb >= 16000 then
    dcli.log.info("Sufficient RAM detected for smooth Windows VM operation")
end

-- CPU virtualization check
if cpu_vendor == "intel" or cpu_vendor == "amd" then
    dcli.log.info("CPU virtualization support: " .. string.upper(cpu_vendor))
else
    dcli.log.warn("Could not detect CPU vendor - verify KVM support manually")
end

-- Core packages (always needed)
table.insert(packages, "curl")
table.insert(packages, "git")
table.insert(packages, "iproute2")
table.insert(packages, "libnotify")
table.insert(packages, "openbsd-netcat")

-- Optional: dialog (for WinApps installer TUI, skip if unavailable)
if dcli.package.is_available("dialog") then
    table.insert(packages, "dialog")
else
    dcli.log.warn("dialog package not available - WinApps installer will use non-interactive mode")
end

-- FreeRDP v3 (critical requirement)
table.insert(packages, "freerdp")

-- Docker backend
if not dcli.package.is_installed("docker") then
    dcli.log.info("Docker not detected - will be installed")
    table.insert(packages, "docker")
    table.insert(packages, "docker-compose")
    table.insert(services.enabled, "docker.service")
else
    dcli.log.info("Docker already installed")
    -- Still enable service if not already
    if not dcli.service.is_enabled("docker.service") then
        table.insert(services.enabled, "docker.service")
    end
end

-- System packages for KVM/networking
if not dcli.package.is_installed("iptables-nft") and not dcli.package.is_installed("iptables") then
    dcli.log.info("Installing iptables for container networking")
    table.insert(packages, "iptables-nft")
end

-- Calculate recommended VM resources for hook
local recommended_ram_gb = math.floor(memory_mb / 1024 * 0.4) -- 40% of system RAM
if recommended_ram_gb < 4 then
    recommended_ram_gb = 4 -- Minimum for Windows 10
elseif recommended_ram_gb > 16 then
    recommended_ram_gb = 16 -- Reasonable maximum
end

local recommended_cores = math.floor(cpu_cores / 2)
if recommended_cores < 2 then
    recommended_cores = 2 -- Minimum for Windows
elseif recommended_cores > 8 then
    recommended_cores = 8 -- Reasonable maximum
end

dcli.log.info(string.format("Recommended VM config: %dGB RAM, %d CPU cores", recommended_ram_gb, recommended_cores))

return {
    description = "WinApps - Seamlessly run Windows applications on Linux via Docker/RDP",
    packages = packages,
    services = services,
    post_install_hook = "scripts/setup-winapps.sh",
    hook_behavior = "ask",
    
    -- Store recommendations as metadata (accessible in hook via env vars)
    metadata = {
        recommended_ram_gb = recommended_ram_gb,
        recommended_cores = recommended_cores,
        total_ram_gb = math.floor(memory_mb / 1024),
        total_cores = cpu_cores,
    },
}
