# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **Don's personal arch-config repository** - a declarative package management system for Arch Linux inspired by NixOS. It uses `dcli` (https://gitlab.com/theblackdon/dcli) to manage system packages through YAML and Lua configuration files.

**Important**: This is a reference/example repository. Users should run `dcli init` to create their own fresh configuration, not clone this directly.

## Architecture

### Core Concept
The system provides NixOS-style declarative package management on Arch Linux with automatic Timeshift/Snapper backups before changes, enabling rollback capability.

### Configuration Hierarchy

The configuration uses a host-based structure with modular package management:

1. **Host files** (`hosts/{hostname}.yaml` or `hosts/{hostname}.lua`) - Main configuration for each machine
2. **Modules** (`modules/*.yaml`, `modules/*.lua`, or `modules/*/module.yaml`) - Reusable package collections
3. **Config pointer** (`config.yaml`) - Points to active host configuration

### Key Files

- **config.yaml**: Points to the active host configuration file
- **hosts/{hostname}.yaml** or **hosts/{hostname}.lua**: Machine-specific configuration including enabled modules, packages, services, and settings
- **modules/*.yaml** or **modules/*.lua**: Optional module collections that can be enabled/disabled
- **modules/*/module.yaml** or **modules/*/module.lua**: Directory-based modules with packages, scripts, and dotfiles
- **state/packages.yaml**: Auto-generated tracking file (do not edit manually)
- **state/hooks.yaml**: Tracks which post-install hooks have been run
- **state/services-state.yaml**: Tracks enabled/disabled services

### Host Configuration Structure

Host files can be YAML or Lua. Lua files allow dynamic configuration based on hardware detection.

**YAML Host File** (`hosts/{hostname}.yaml`):
```yaml
host: hostname
description: Human-readable description

# Import shared configs (optional)
import:
  - hosts/shared/common.yaml

# Enable modules
enabled_modules:
  - gaming
  - development

# Host-specific packages
packages:
  - firefox
  - discord
  - flatpak:com.spotify.Client

# Exclude packages from modules/base
exclude:
  - vim  # Use neovim instead

# Services
services:
  enabled:
    - bluetooth
    - sshd
  disabled:
    - cups

# Settings
flatpak_scope: user     # "user" or "system"
auto_prune: false       # Auto-remove unmanaged packages
aur_helper: paru        # AUR helper (paru, yay, etc.)
editor: nano            # Editor for config files

# Config backups
config_backups:
  enabled: true
  max_backups: 5

# System backups (Timeshift/Snapper)
system_backups:
  enabled: true
  backup_on_sync: true
  backup_on_update: true
  tool: timeshift       # timeshift or snapper
  snapper_config: root  # Snapper config name (if using snapper)

# Dotfiles management
dotfiles:
  - source: zshrc
    target: ~/.zshrc
  - hypr  # Shorthand for dotfiles/hypr → ~/.config/hypr
```

**Lua Host File** (`hosts/{hostname}.lua`):
```lua
-- Dynamic host configuration with hardware detection
local packages = { "firefox", "neovim" }
local modules = { "base", "cli-tools" }

-- Add GPU drivers based on detected hardware
if dcli.hardware.has_nvidia() then
    table.insert(modules, "nvidia-drivers")
elseif dcli.hardware.has_amd_gpu() then
    table.insert(modules, "amd-drivers")
end

-- Enable docker if we have enough RAM
if dcli.system.memory_total_mb() >= 16000 then
    table.insert(modules, "docker")
end

return {
    host = dcli.system.hostname(),
    description = "Workstation with auto-detected hardware",
    enabled_modules = modules,
    packages = packages,
    flatpak_scope = "user",
    aur_helper = "paru",
}
```

### Module Structure

Modules can be YAML, Lua, or directory-based.

**Simple YAML Module** (`modules/gaming.yaml`):
```yaml
description: Gaming packages

packages:
  - steam
  - lutris
  - wine
  - gamemode

conflicts:
  - server-only

post_install_hook: scripts/setup-gaming.sh
hook_behavior: ask  # ask | always | once | skip
```

**Lua Module** (`modules/gpu-drivers.lua`):
```lua
-- Hardware-conditional GPU drivers
local packages = {}

if dcli.hardware.has_nvidia() then
    table.insert(packages, "nvidia")
    table.insert(packages, "nvidia-utils")
elseif dcli.hardware.has_amd_gpu() then
    table.insert(packages, "mesa")
    table.insert(packages, "vulkan-radeon")
end

return {
    description = "GPU drivers (auto-detected)",
    packages = packages,
}
```

**Directory-Based Module** (`modules/hyprland/`):
```
modules/hyprland/
├── module.yaml              # or module.lua
├── packages.yaml            # Main packages
├── packages-optional.yaml   # Optional packages
├── scripts/
│   └── setup.sh            # Post-install hook
└── dotfiles/               # Configuration files
    ├── hypr/
    └── waybar/
```

### Module Features

- **Conflicts**: Modules can declare conflicts with other modules
- **Post-install hooks**: Bash scripts that run after module installation
- **Directory-based modules**: Complex modules with multiple package files, scripts, and dotfiles
- **Lua support**: Dynamic modules with hardware detection and conditional logic
- **Nested modules**: Organize modules in subdirectories (e.g., `modules/dev/python/`)

## Common Commands

### Package Management

```bash
dcli search                    # Interactive package search (TUI)
dcli install <package>         # Install and add to config
dcli remove <package>          # Remove package
dcli update                    # Update system packages
dcli find <package>            # Find where package is defined
dcli merge                     # Add unmanaged packages to config
dcli merge --services          # Add enabled services to config
```

### Module Management

```bash
dcli module list               # Show all available modules and status
dcli module enable             # Interactive selection (TUI)
dcli module enable <name>      # Enable specific module
dcli module disable            # Interactive selection (TUI)
dcli module disable <name>     # Disable specific module
dcli module run-hook <name>    # Run module's post-install hook
```

### Package Synchronization

```bash
dcli sync                      # Install missing packages (creates backup first)
dcli sync --dry-run            # Preview changes without applying
dcli sync --prune              # Also remove unmanaged packages
dcli sync --force-dotfiles     # Force re-sync dotfiles
dcli sync --no-hooks           # Skip post-install hooks
dcli sync --no-backup          # Skip automatic backup
```

### Configuration

```bash
dcli status                    # Show current configuration and sync status
dcli validate                  # Check config integrity
dcli validate --check-packages # Also verify packages exist
dcli edit                      # Interactive file editor (TUI)
dcli migrate                   # Migrate to new structure
```

### Backups

**Configuration Backups:**
```bash
dcli save-config               # Backup current config
dcli restore-config            # Interactive restore (TUI)
```

**System Snapshots:**
```bash
dcli backup                    # Create system snapshot
dcli backup list               # List snapshots
dcli backup delete <id>        # Delete snapshot
dcli backup check              # Check backup status
dcli restore [<id>]            # Interactive restore (TUI)
```

### Hooks

```bash
dcli hooks list                # Show all hooks and status
dcli hooks run [<module>]      # Interactive selection (TUI)
dcli hooks skip <module>       # Mark hook as skipped
dcli hooks reset <module>      # Reset hook to run again
```

### Git Repository

```bash
dcli repo init                 # Set up git for arch-config
dcli repo clone                # Clone existing arch-config
dcli repo push                 # Commit and push changes
dcli repo pull                 # Pull updates from remote
dcli repo status               # Show git status
```

### Maintenance

```bash
dcli self-update               # Update dcli itself
dcli help                      # Show help
dcli <command> --json          # JSON output for scripting
```

## Lua API

dcli provides a comprehensive Lua API for dynamic configuration. Available in both host files and modules.

### Hardware Detection

```lua
dcli.hardware.cpu_vendor()        -- "intel", "amd", or "unknown"
dcli.hardware.gpu_vendors()       -- Array of GPU vendors
dcli.hardware.has_nvidia()        -- Check for NVIDIA GPU
dcli.hardware.has_amd_gpu()       -- Check for AMD GPU
dcli.hardware.has_intel_gpu()     -- Check for Intel GPU
dcli.hardware.is_laptop()         -- Check if system is a laptop
dcli.hardware.chassis_type()      -- "desktop", "laptop", "server", etc.
```

### System Information

```lua
dcli.system.hostname()            -- Current hostname
dcli.system.memory_total_mb()     -- Total RAM in MB
dcli.system.cpu_cores()           -- Number of CPU cores
dcli.system.kernel_version()      -- Kernel version string
dcli.system.arch()                -- "x86_64", "aarch64", etc.
```

### Package Queries

```lua
dcli.package.is_installed("vim")  -- Check if package installed
dcli.package.is_available("pkg")  -- Check if package available
```

### Service Detection

```lua
dcli.service.is_active("sshd")    -- Check if service is running
dcli.service.is_enabled("sshd")   -- Check if service is enabled
```

### File Operations

```lua
dcli.file.exists("/path/to/file") -- Check file existence
dcli.file.is_dir("/path/to/dir")  -- Check if path is directory
```

### Environment Variables

```lua
dcli.env.home()                   -- User home directory
dcli.env.get("VAR")               -- Get environment variable
```

### Utility Functions

```lua
dcli.util.contains(table, value)  -- Check if table contains value
dcli.util.merge(t1, t2)           -- Merge two tables
```

### Logging

```lua
dcli.log.info("message")          -- Info log
dcli.log.warn("message")          -- Warning log
dcli.log.error("message")         -- Error log
dcli.log.debug("message")         -- Debug log
```

See `.Documentation/DCLI-LUA-API.md` for complete API reference.

## Dotfiles Management

dcli includes a powerful dotfiles management system inspired by GNU Stow, with automatic conflict detection and flexible path mapping.

### Dotfiles Configuration

Modules can define dotfiles in three ways:

**1. Automatic Mode (Legacy):**
```yaml
# In module.yaml or dotfiles.yaml
automatic: true
```
Syncs everything in `dotfiles/` to `~/.config/` (directories only)

**2. Shorthand Mode:**
```yaml
# In dotfiles.yaml
dotfiles:
  - hypr          # dotfiles/hypr → ~/.config/hypr
  - waybar        # dotfiles/waybar → ~/.config/waybar
```

**3. Explicit Mode:**
```yaml
# In dotfiles.yaml
dotfiles:
  - source: zshrc
    target: ~/.zshrc
  - source: local/bin/script.sh
    target: ~/.local/bin/script.sh
```

### Conflict Detection

If multiple modules try to sync to the same target, dcli will error with details about the conflicting modules. Update `dotfiles.yaml` to use different target paths.

### Commands

```bash
dcli sync                    # Sync dotfiles during normal sync
dcli sync --force-dotfiles   # Force re-sync even if already synced
dcli sync --prune            # Remove dotfiles from disabled modules
```

## Services Management

Declaratively manage systemd services in host configuration:

```yaml
services:
  enabled:
    - bluetooth    # Enable and start
    - sshd
    - docker
  disabled:
    - cups         # Stop and disable
```

Bootstrap from current system:
```bash
dcli merge --services           # Add enabled services to config
dcli merge --services --dry-run # Preview first
```

Services sync automatically during `dcli sync`.

**Important**: When using `dcli merge --services`, system-critical services (systemd-*, dbus, getty, etc.) are automatically filtered out. See `.Documentation/SERVICES.md` for details.

## Flatpak Support

Two ways to declare flatpak packages:

```yaml
packages:
  - firefox                          # Regular pacman package
  - flatpak:com.spotify.Client      # Flatpak (prefix format)
  - name: org.videolan.VLC           # Flatpak (object format)
    type: flatpak
```

Set installation scope in host file:
```yaml
flatpak_scope: user  # "user" (default) or "system"
```

## Development Patterns

### Creating New Modules

**Simple Module:**
1. Create file in `modules/<module-name>.yaml` or `modules/<module-name>.lua`
2. Add description and packages
3. Optionally add conflicts, hooks, or services

**Directory Module:**
1. Create directory `modules/<module-name>/`
2. Add `module.yaml` or `module.lua` manifest
3. Add `packages.yaml` or multiple `packages-*.yaml` files
4. Optionally add `scripts/` and `dotfiles/` directories

**Lua Module (Hardware-Conditional):**
```lua
-- modules/laptop-power.lua
if not dcli.hardware.is_laptop() then
    return {
        description = "Laptop power management (skipped - not a laptop)",
        packages = {},
    }
end

return {
    description = "Laptop power management",
    packages = {
        "tlp",
        "powertop",
        "acpi",
    },
    services = {
        enabled = { "tlp.service" },
    },
}
```

### Post-Install Hooks

Hooks are bash scripts in `scripts/` directory that:
- Handle sudo/permissions appropriately
- Use `ARCH_CONFIG_DIR` environment variable for paths
- Can install udev rules, configure services, etc.

Hook behaviors:
- `ask` - Prompt before running (default)
- `always` - Run every sync, no questions
- `once` - Run once without prompting
- `skip` - Never run this hook

### Host-Specific Configuration

The `exclude` array in host configs removes packages from modules or base:
```yaml
exclude:
  - tlp                    # Exclude laptop packages on desktop
  - laptop-mode-tools
```

### Config Import

Share configurations across hosts:
```yaml
# hosts/laptop.yaml
import:
  - hosts/shared/common.yaml
  - hosts/shared/laptop-base.yaml
```

## System Backups

dcli supports two backup tools:

### Timeshift
```yaml
system_backups:
  enabled: true
  backup_on_sync: true
  backup_on_update: true
  tool: timeshift
```

### Snapper
```yaml
system_backups:
  enabled: true
  backup_on_sync: true
  backup_on_update: true
  tool: snapper
  snapper_config: root  # Snapper configuration name
```

Backups are created automatically before `dcli sync` and `dcli update` operations when enabled.

## Configuration Format Requirements

- All package arrays use vertical formatting (one package per line) for easy git management
- Modules use `conflicts` array for declaring incompatibilities
- Post-install hooks reference scripts with path relative to module root
- Both simple string format and object format are supported for packages
- Lua files must return a table with the configuration
- Service names can be with or without `.service` suffix

## Migration

Old structure (`packages/` directory) is still supported, but new installations use:
- `modules/` instead of `packages/modules/`
- `hosts/` instead of `packages/hosts/`
- `config.yaml` as pointer to active host
- Full host configuration in host files

Migration command:
```bash
dcli migrate --dry-run  # Preview changes
dcli migrate            # Perform migration (creates backup)
```

## JSON Output

All commands support JSON for scripting:
```bash
dcli status --json
dcli module list --json
dcli find vim --json
dcli hooks list --json
```

## Current System Configuration

**Hostname**: don-desktop
**Enabled Modules**: Check with `dcli status` or `dcli module list`
**Configuration**: See `~/.config/arch-config/hosts/don-desktop.yaml`

## Important Notes

- **State tracking**: `state/packages.yaml` tracks dcli-managed packages for safe pruning
- **Automatic backups**: By default, `dcli sync` creates system snapshots before changes
- **Module conflicts**: System will prompt when enabling conflicting modules
- **Git integration**: This repo is version controlled; changes should be committed to track configuration evolution
- **Dotfiles**: Managed through symlinks with automatic conflict detection
- **Services**: Systemd services can be declared alongside packages
- **Flatpak support**: Seamless integration with flatpak packages
- **TUI features**: Interactive commands require `fzf` to be installed
- **Lua support**: Dynamic configuration with hardware detection
- **Directory modules**: Organize complex modules with multiple files

## Documentation Files

### Main Documentation
- **README.md**: Comprehensive user documentation
- **DOTFILES-SYMLINK-GUIDE.md**: Detailed dotfiles management guide
- **CONTROLLER_SUPPORT.md**: Example of advanced module with udev rules
- **CLAUDE.md**: This file - Developer/AI assistant guidance

### Extended Documentation (`.Documentation/`)
- **CHEAT-SHEET.md**: Quick reference for all dcli commands
- **DCLI-LUA-API.md**: Complete Lua API reference with examples
- **LUA-HOSTS.md**: Guide to writing dynamic Lua host configurations
- **LUA-MODULES.md**: Guide to writing Lua modules with conditionals
- **DIRECTORY-MODULES.md**: Guide to directory-based module structure
- **SERVICES.md**: Detailed systemd services management guide

**Tip**: When working with Lua configuration or advanced features, refer to the appropriate guide in `.Documentation/` for comprehensive examples and API reference.

## AUR Package

dcli is available on the AUR as `dcli-arch-git`:
```bash
yay -S dcli-arch-git
# or
paru -S dcli-arch-git
```

## Tips for AI Assistants

- **Check for Lua files first**: When looking for host or module configs, check for `.lua` files as they take precedence over `.yaml`
- **Use hardware detection APIs**: When creating conditional configs, leverage `dcli.hardware.*` and `dcli.system.*` APIs
- **Directory modules for complexity**: Suggest directory-based modules for anything with multiple package files, scripts, or dotfiles
- **Reference documentation**: Point users to specific `.Documentation/*.md` files for detailed guides
- **Validate before sync**: Always suggest `dcli validate` before `dcli sync` to catch errors early
- **Preview with --dry-run**: Recommend `--dry-run` flag for preview before making changes
- **JSON for scripting**: Use `--json` flag when parsing command output programmatically
