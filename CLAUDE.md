# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **Don's personal arch-config repository** - a declarative package management system for Arch Linux inspired by NixOS. It uses `dcli` (https://gitlab.com/theblackdon/dcli) to manage system packages through YAML configuration files.

**Important**: This is a reference/example repository. Users should run `dcli init` to create their own fresh configuration, not clone this directly.

## Architecture

### Core Concept
The system provides NixOS-style declarative package management on Arch Linux with automatic Timeshift/Snapper backups before changes, enabling rollback capability.

### Configuration Hierarchy

The configuration uses a host-based structure with modular package management:

1. **Host files** (`hosts/{hostname}.yaml`) - Main configuration for each machine
2. **Modules** (`modules/*.yaml` or `modules/*/module.yaml`) - Reusable package collections
3. **Config pointer** (`config.yaml`) - Points to active host configuration

### Key Files

- **config.yaml**: Points to the active host configuration file
- **hosts/{hostname}.yaml**: Machine-specific configuration including enabled modules, packages, services, and settings
- **modules/*.yaml**: Optional module collections that can be enabled/disabled
- **state/installed.yaml**: Auto-generated tracking file (do not edit manually)
- **state/hook-status.yaml**: Tracks which post-install hooks have been run
- **state/dotfiles-synced.yaml**: Tracks synced dotfiles

### Host Configuration Structure

Each host YAML file contains:
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

### Module Structure

Each module YAML file contains:
```yaml
description: Human-readable description

packages:
  - package-one
  - package-two
  - flatpak:com.example.App
  - name: org.example.AnotherApp
    type: flatpak

conflicts:
  - other-module-name

post_install_hook: scripts/script-name.sh  # Optional
hook_behavior: ask  # ask | always | once | skip
```

**Module Features**:
- **Conflicts**: Modules can declare conflicts with other modules
- **Post-install hooks**: Bash scripts that run after module installation
- **Directory-based modules**: Complex modules can use `modules/{name}/module.yaml` structure
- **Dotfiles support**: Modules can include `dotfiles/` directory or `dotfiles.yaml` for configuration files

### Directory-Based Modules

For complex modules, use a directory structure:
```
modules/
└── hyprland/
    ├── module.yaml          # Main module definition
    ├── packages.yaml        # Package list
    ├── dotfiles.yaml        # Dotfiles configuration
    └── dotfiles/            # Configuration files to sync
        ├── hypr/
        └── waybar/
```

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
```

### Package Synchronization

```bash
dcli sync                      # Install missing packages (creates backup first)
dcli sync --dry-run            # Preview changes without applying
dcli sync --prune              # Also remove unmanaged packages
dcli sync --force-dotfiles     # Force re-sync dotfiles
```

### Configuration

```bash
dcli status                    # Show current configuration and sync status
dcli validate                  # Check config integrity
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
dcli restore                   # Interactive restore (TUI)
```

### Hooks

```bash
dcli hooks list                # Show all hooks and status
dcli hooks run                 # Interactive selection (TUI)
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

1. Create file in `modules/<module-name>.yaml` or `modules/<module-name>/module.yaml`
2. Add description, packages, and optional conflicts
3. If complex setup is needed, create a post-install hook script in `scripts/`
4. For dotfiles, create `dotfiles/` directory or `dotfiles.yaml`

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

## YAML Format Requirements

- All package arrays use vertical formatting (one package per line) for easy git management
- Modules use `conflicts` array for declaring incompatibilities
- Post-install hooks reference scripts with path relative to repo root
- Both simple string format and object format are supported for packages

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
```

## Current System Configuration

**Hostname**: don-asus
**Enabled Modules**: Check with `dcli status` or `dcli module list`
**Configuration**: See `~/.config/arch-config/hosts/don-asus.yaml`

## Important Notes

- **State tracking**: `state/installed.yaml` tracks dcli-managed packages for safe pruning
- **Automatic backups**: By default, `dcli sync` creates system snapshots before changes
- **Module conflicts**: System will prompt when enabling conflicting modules
- **Git integration**: This repo is version controlled; changes should be committed to track configuration evolution
- **Dotfiles**: Managed through symlinks with automatic conflict detection
- **Services**: Systemd services can be declared alongside packages
- **Flatpak support**: Seamless integration with flatpak packages
- **TUI features**: Interactive commands require `fzf` to be installed

## Documentation Files

- **README.md**: Comprehensive user documentation
- **DOTFILES-SYMLINK-GUIDE.md**: Detailed dotfiles management guide
- **CONTROLLER_SUPPORT.md**: Example of advanced module with udev rules
- This file (CLAUDE.md): Developer/AI assistant guidance

## AUR Package

dcli is available on the AUR as `dcli-arch-git`:
```bash
yay -S dcli-arch-git
# or
paru -S dcli-arch-git
```
