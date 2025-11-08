# arch-config - Don's Personal Configuration

> **Note**: This is Don's personal arch-config repository, provided as an **example and reference** for others.
> 
> **For new users**: Do NOT clone this repository directly. Instead:
> 1. Install [dcli](https://gitlab.com/yourname/dcli)
> 2. Run `dcli init` to create your own fresh configuration
> 3. Use this repo as a reference for creating your own modules and configurations

This directory contains a declarative package configuration for Arch Linux, inspired by NixOS.

## Directory Structure

```
arch-config/
├── config.json              # Main configuration
├── packages/
│   ├── base.json           # Core system packages (always installed)
│   ├── modules/            # Optional package collections
│   │   ├── mangowc.json
│   │   ├── hyprland.json
│   │   ├── gaming.json
│   │   └── multimedia.json
│   └── hosts/              # Host-specific packages
│       └── <hostname>.json
└── state/
    └── installed.json      # Tracked installed packages (auto-generated)
```

## Quick Start

### 1. Configure Your System

Edit `config.json` to set your hostname and additional packages:

```json
{
  "host": "your-hostname",
  "enabled_modules": [],
  "additional_packages": [
    "firefox",
    "discord"
  ],
  "auto_prune": false
}
```

### 2. Add Base Packages

Edit `packages/base.json` to define packages that should be on all machines:

```json
{
  "name": "base",
  "description": "Core system packages for all machines",
  "packages": [
    "base-devel",
    "git",
    "vim",
    "htop",
    "fish",
    "fastfetch"
  ]
}
```

### 3. Enable Modules

```bash
# See available modules
dcli module list

# Enable a module
dcli module enable gaming

# Disable a module
dcli module disable gaming
```

### 4. Sync Packages

```bash
# Preview changes (dry-run)
dcli sync -d

# Apply changes (install missing packages)
# NOTE: Automatically creates a Timeshift backup before applying changes!
dcli sync

# Apply changes and remove unmanaged packages
dcli sync --prune

# Skip all prompts (still creates backup)
dcli sync --force

# Skip automatic backup (not recommended)
dcli sync --no-backup
```

**Automatic Backups:** By default, `dcli sync` creates a Timeshift snapshot before making any changes. This gives you NixOS-style rollback capability! If something goes wrong, simply run `dcli restore` to rollback.

## Commands

### Module Management

- `dcli module list` - Show all available modules and their status
- `dcli module enable <name>` - Enable a module
- `dcli module disable <name>` - Disable a module

### Package Synchronization

- `dcli sync` - Install packages to match configuration
- `dcli sync -d` or `dcli sync --dry-run` - Preview changes
- `dcli sync --prune` - Remove packages not in configuration
- `dcli sync --force` - Skip confirmation prompts

### Status

- `dcli status` - Show current configuration and sync status

## Creating Modules

Create a new module file in `packages/modules/`:

```json
{
  "name": "mymodule",
  "description": "Description of what this module provides",
  "conflicts": ["other-module"],
  "packages": [
    "package-one",
    "package-two",
    "package-three"
  ]
}
```

### Module Fields

- **name**: Module identifier (must match filename)
- **description**: Human-readable description
- **conflicts** (optional): Array of module names that conflict with this one
- **packages**: Array of package names to install

## Host-Specific Configuration

Each host can have its own package file in `packages/hosts/<hostname>.json`:

```json
{
  "name": "desktop",
  "description": "Desktop machine specific packages",
  "packages": [
    "nvidia-dkms",
    "nvidia-utils"
  ],
  "exclude": [
    "tlp",
    "laptop-mode-tools"
  ]
}
```

The `exclude` array removes packages from other sources (useful for avoiding laptop-only packages on desktop).

## Package Merge Order

Packages are merged in this order:
1. `base.json` - Core packages
2. `hosts/<hostname>.json` - Host-specific packages
3. Enabled modules - All enabled module packages
4. `additional_packages` from config.json

Duplicates are automatically removed, and excluded packages are filtered out.

## Conflict Detection

When enabling a module that conflicts with an already-enabled module, you'll be prompted with options:
1. Disable the conflicting module and enable the new one
2. Enable both anyway (not recommended)
3. Cancel

The `dcli status` command will show warnings if conflicting modules are enabled.

## State Tracking

The `state/installed.json` file tracks which packages are managed by dcli. This file is auto-generated and should not be manually edited. It's used to determine which packages are safe to remove with `--prune`.

## Tips

- **Start small**: Begin with just base packages and one module
- **Use dry-run**: Always test with `-d` before syncing
- **Regular backups**: Use `dcli backup` before major changes
- **Module conflicts**: Define conflicts to prevent incompatible packages
- **Host files**: Use host files for machine-specific hardware packages
- **Vertical lists**: All JSON arrays use vertical formatting for easy management

## Example Workflow

```bash
# Initialize (if not already done)
dcli init

# Edit base packages
vim ~/.config/arch-config/packages/base.json

# Enable modules for your use case
dcli module enable mangowc
dcli module enable development

# Preview changes
dcli sync -d

# Apply changes
dcli sync

# Check status
dcli status

# Later: add a package temporarily
vim ~/.config/arch-config/config.json
# Add to "additional_packages" array

# Sync again
dcli sync
```

## Troubleshooting

**Module not found**: Run `dcli module list` to see available modules

**Conflicts**: Run `dcli status` to see conflict warnings

**JSON errors**: Validate JSON syntax at https://jsonlint.com/

**State issues**: Delete `state/installed.json` to reset tracking (will mark all packages as new)

## Advanced: Using with Git

Track your configuration in git:

```bash
cd ~/.config/arch-config
git init
git add config.json packages/
git commit -m "Initial declarative config"
```

This lets you version control your system configuration and sync it across machines!


```
```
README.md

## Packages
- `packages/base.json` - Core packages always installed
- `packages/modules/` - Optional module collections
  - `controller-support.json` - Game controller support packages
  - `gaming.json` - Gaming-related packages
  - `hyprland.json` - Hyprland window manager and tools
  - `mangowc.json` - MangoWC window manager (custom Wayland compositor)
  - `multimedia.json` - Multimedia tools and codecs
  - `development.json` - Development tools and IDEs
- `packages/hosts/` - Host-specific package configurations

## State
- `state/installed.json` - Auto-generated tracking of installed packages

## Scripts
- `scripts/` - Custom scripts and utilities
  - `backup.sh` - Backup script
  - `restore.sh` - Restore script

## Udev Rules
- `udev-rules/` - Custom udev rules for device management

## Automation & Backups
- `AUTOMATIC_BACKUPS.md` - Information about automatic backup functionality
- `CONTROLLER_SUPPORT.md` - Guide for controller support packages and configuration

---

## Using This Repository as a Reference

This is Don's personal configuration. Here's how to use it as inspiration for your own setup:

### 1. Install dcli first

```bash
git clone https://gitlab.com/yourname/dcli.git
cd dcli
./install.sh
```

### 2. Create your own configuration

```bash
dcli init  # Creates fresh config at ~/.config/arch-config
```

### 3. Browse this repository for ideas

- **Modules**: Check out `packages/modules/` for module examples:
  - `controller-support.json` - Game controller setup with post-install hooks
  - `gaming.json` - Gaming packages
  - `hyprland.json` - Hyprland window manager setup
  - `mangowc.json` - Custom Wayland compositor
  
- **Scripts**: Look at `scripts/` for post-install hook examples:
  - `install-controller-udev-rules.sh` - How to install udev rules via hooks

- **Host configs**: See `packages/hosts/don-eos.json` for host-specific package examples

### 4. Copy and adapt what you need

Feel free to copy module structures, package lists, or scripts from this repo and adapt them to your needs.

### Don's Setup

This configuration is for a system running:
- **Hostname**: don-eos
- **Enabled modules**: controller-support
- **Use case**: Gaming, development, and daily use on Arch-based EndeavourOS

### Key Modules in This Config

- **controller-support**: Xbox/PlayStation controller support with automatic udev rules installation
- **gaming**: Steam, Lutris, and gaming tools
- **hyprland**: Hyprland Wayland compositor
- **mangowc**: Custom Wayland compositor configuration
- **asus**: ASUS laptop-specific tools
- **lazyvim**: LazyVim Neovim distribution dependencies

---

## License

This configuration is provided as-is for reference. Feel free to use and adapt as needed.