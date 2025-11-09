# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **Don's personal arch-config repository** - a declarative package management system for Arch Linux inspired by NixOS. It uses `dcli` (https://gitlab.com/theblackdon/dcli) to manage system packages through YAML configuration files.

**Important**: This is a reference/example repository. Users should run `dcli init` to create their own fresh configuration, not clone this directly.

## Architecture

### Core Concept
The system provides NixOS-style declarative package management on Arch Linux with automatic Timeshift backups before changes, enabling rollback capability.

### Configuration Hierarchy

Packages are merged in this order (later overrides earlier):
1. `packages/base.yaml` - Core packages for all machines
2. `packages/hosts/<hostname>.yaml` - Host-specific packages (supports `exclude` array)
3. Enabled modules from `packages/modules/` - Optional package collections
4. `additional_packages` in `config.yaml` - One-off packages

### Key Files

- **config.yaml**: Main configuration defining hostname, enabled modules, additional packages, and auto-prune setting
- **packages/base.yaml**: Foundation packages installed on all machines
- **packages/modules/*.yaml**: Optional module collections that can be enabled/disabled
- **packages/hosts/*.yaml**: Machine-specific packages (can exclude packages from other sources)
- **state/installed.yaml**: Auto-generated tracking file (do not edit manually)

### Module Structure

Each module YAML file contains:
```yaml
description: Human-readable description

packages:
  - package-one
  - package-two

conflicts:
  - other-module-name

post_install_hook: scripts/script-name.sh  # Optional
```

**Module Features**:
- **Conflicts**: Modules can declare conflicts with other modules (e.g., `hyprland` vs `mangowc`)
- **Post-install hooks**: Bash scripts that run after module installation (see controller-support module)
- All YAML arrays use vertical formatting for easy git management

## Common Commands

### Module Management
```bash
dcli module list                 # Show all available modules and status
dcli module enable <name>        # Enable a module
dcli module disable <name>       # Disable a module
```

### Package Synchronization
```bash
dcli sync                        # Install missing packages (creates Timeshift backup first)
dcli sync -d                     # Dry-run: preview changes without applying
dcli sync --prune                # Remove unmanaged packages
dcli sync --force                # Skip prompts (still creates backup)
dcli sync --no-backup            # Skip automatic Timeshift backup (not recommended)
```

### Status
```bash
dcli status                      # Show current configuration and sync status
```

### Backup/Restore
```bash
dcli restore                     # Rollback using Timeshift backup
```

## Development Patterns

### Creating New Modules

1. Create file in `packages/modules/<module-name>.yaml`
2. Use vertical array formatting for packages
3. Add description and conflicts if applicable
4. If complex setup is needed, create a post-install hook script in `scripts/`

### Post-Install Hooks

Example from `controller-support.yaml`:
- Hooks are bash scripts in `scripts/` directory
- Must handle sudo/permissions appropriately
- Should use `ARCH_CONFIG_DIR` environment variable for paths
- Can install udev rules, configure services, etc.

See `scripts/install-controller-udev-rules.sh` for a complete example that:
- Checks for sudo
- Copies udev rules from `udev-rules/` to `/etc/udev/rules.d/`
- Reloads udev and triggers application
- Loads kernel modules and configures boot

### Host-Specific Configuration

The `exclude` array in host configs removes packages from other sources:
```yaml
exclude:
  - tlp                    # Exclude laptop packages on desktop
  - laptop-mode-tools
```

This is useful when a package appears in base.yaml or modules but shouldn't be installed on specific machines.

## YAML Format Requirements

- All package arrays must use vertical formatting (one package per line)
- Modules use `conflicts` array, not individual fields
- Post-install hooks reference scripts with path relative to repo root
- YAML syntax is validated by go-yq (installed in base packages)

## Current System Configuration

**Hostname**: don-asus  
**Enabled Modules**: asus, mangowc, main-apps  
**Auto-prune**: false

## Important Notes

- **State tracking**: `state/installed.yaml` tracks dcli-managed packages for safe pruning
- **Automatic backups**: By default, `dcli sync` creates Timeshift snapshots before changes
- **Module conflicts**: System will prompt when enabling conflicting modules (e.g., hyprland vs mangowc)
- **Git integration**: This repo is version controlled; changes should be committed to track configuration evolution
