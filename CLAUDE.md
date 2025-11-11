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

### System Updates
```bash
dcli update                      # Update system packages (respects version constraints)
                                 # Pinned packages are automatically excluded from updates
```

**Note**: `dcli update` now respects version constraints. Packages with exact version pins or maximum constraints will NOT be updated. Use `dcli unpin <package>` to allow updates, or `dcli sync` to manage versions declaratively.

### Version Pinning (NixOS-like)
```bash
dcli lock                        # Generate lockfile with all current package versions
dcli pin <package> [version]     # Pin a package to specific version (current if omitted)
dcli unpin <package>             # Remove version constraint
dcli versions <package>          # Show version info (installed, available, cached)
dcli outdated                    # Show packages that don't match constraints
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

### Version Pinning (NixOS-Inspired)

**Overview**: dcli now supports version pinning similar to NixOS, allowing you to lock packages to specific versions for reproducibility.

#### Package Syntax

Packages can be declared in two formats:

**Simple format** (always uses latest version):
```yaml
packages:
  - vim
  - git
  - firefox
```

**Object format** (with version constraints):
```yaml
packages:
  - name: vim
    version: "9.0.1234-1"           # Exact version (epoch:version-release)
  - name: git
    version: ">=2.40.0-1"           # Minimum version
  - name: curl
    version: "<8.0.0-1"             # Maximum version
  - firefox                         # Can mix with simple format
```

#### Version Constraint Types

1. **Exact version**: `"9.0.1234-1"` - Package must be exactly this version
2. **Minimum version**: `">=2.40.0-1"` - Package must be at least this version
3. **Maximum version**: `"<8.0.0-1"` - Package must be below this version
4. **Latest** (no constraint): Omit version field or use simple string format

#### Version Format

Arch Linux uses the format: `[epoch:]version-release`

- **epoch** (optional): Integer used when versioning scheme changes (e.g., `1:2.40.1-1`)
- **version**: Upstream version number (e.g., `2.40.1`)
- **release**: Arch packaging release number (e.g., `-1`, `-2`)

**Examples**:
- `vim` package: `2:9.0.1234-1` (epoch 2, version 9.0.1234, release 1)
- `git` package: `2.40.1-1` (no explicit epoch = epoch 0)
- `linux` package: `6.6.1.arch1-1`

#### Rolling Packages (-git)

Packages ending in `-git` (e.g., `neovim-git`, `mangowc-git`) build from HEAD of their git repository and **cannot be pinned** to specific versions. These are rolling releases by nature.

**Best practice**: Use stable releases instead of `-git` packages when version pinning is important.

#### Workflow Examples

**Pin current system state** (like NixOS flake.lock):
```bash
dcli lock                           # Generates state/locked-versions.yaml
git add state/locked-versions.yaml
git commit -m "Lock package versions"
```

**Pin a specific package**:
```bash
dcli versions firefox               # Check available versions
dcli pin firefox 131.0-1            # Pin to specific version
dcli sync                           # Apply the constraint
```

**Pin package to currently installed version**:
```bash
dcli pin vim                        # Uses current version automatically
```

**Upgrade with constraints respected**:
```bash
dcli outdated                       # Check version mismatches
dcli sync                           # Upgrades/downgrades to meet constraints
```

#### Downgrades

When `dcli sync` detects a package needs downgrading to meet constraints, it:

1. Shows all packages requiring downgrades with current → target versions
2. Prompts for selection: all, none, or specific packages (comma-separated)
3. Attempts downgrade from local cache (`/var/cache/pacman/pkg/`)
4. Falls back to Arch Linux Archive if not in cache
5. Skips package if version unavailable

**Arch Linux Archive**: Historical package versions are available at `https://archive.archlinux.org`

#### Example Configurations

**Base packages with some pinned** (`packages/base.yaml`):
```yaml
packages:
  - base
  - linux
  - name: linux-firmware
    version: "20231030-1"           # Pin firmware to tested version
  - networkmanager
  - name: vim
    version: ">=9.0.0-1"            # Require at least vim 9
  - git
  - go-yq
```

**Module with version constraints** (`packages/modules/development.yaml`):
```yaml
description: Development tools with version control

packages:
  - name: python
    version: "3.11.5-1"             # Pin Python version for compatibility
  - name: nodejs
    version: ">=20.0.0-1"           # Require Node 20 or higher
  - rust                            # Latest Rust always
  - docker
```

**Host-specific pins** (`packages/hosts/don-asus.yaml`):
```yaml
packages:
  - name: nvidia
    version: "545.29.06-1"          # Pin GPU driver to stable version
  - name: linux
    version: "6.6.1.arch1-1"        # Pin kernel with tested driver
```

#### Lockfile Structure

The lockfile (`state/locked-versions.yaml`) generated by `dcli lock` tracks exact versions:

```yaml
# Lockfile generated by dcli lock
# Generated: 2025-01-15T10:30:00Z

packages:
  - name: vim
    version: "2:9.0.1234-1"
  - name: firefox
    version: "131.0-1"
  - name: neovim-git
    version: "r8942.abc1234"
    rolling: true                   # Marked as rolling release
```

**Usage**:
- Commit lockfile to git for reproducible deployments
- Use to restore exact package state on new machines
- Compare lockfiles across systems with `git diff`

#### Limitations

1. **Repository retention**: Arch repos only keep latest versions; older versions require Arch Archive
2. **AUR packages**: Version pinning works but archive availability varies by package
3. **Rolling packages**: Cannot pin `-git` packages to specific commits
4. **Dependencies**: Pinning a package doesn't pin its dependencies (Arch Linux limitation)

#### System Updates with Version Constraints

When running `dcli update`, the system automatically respects version constraints:

```bash
dcli update  # Updates all packages EXCEPT those with constraints
```

**Behavior**:
- Packages with **exact version pins** (`version: "1.2.3-1"`) are excluded from updates
- Packages with **maximum constraints** (`version: "<2.0.0-1"`) are excluded from updates
- Packages with **minimum constraints** (`version: ">=1.0.0-1"`) CAN be updated (they meet the minimum)
- Packages with **no constraints** are updated normally

**Example Output**:
```
Checking for version constraints...

The following packages have version constraints and will NOT be updated:
  • linux (6.6.1.arch1-1)
  • nvidia (545.29.06-1)

These packages are pinned. Use 'dcli unpin <package>' to allow updates.

Running system update (respecting version constraints)...
```

#### Best Practices

1. **Test before pinning**: Let packages update naturally, test, then pin working versions
2. **Pin strategically**: Don't pin everything; focus on critical packages (kernel, drivers, toolchains)
3. **Use `dcli update` freely**: It respects your pins automatically - no manual intervention needed
4. **Regular lockfiles**: Run `dcli lock` and commit after successful updates
5. **Document reasons**: Add comments in YAML explaining why specific versions are pinned
6. **Monitor constraints**: Run `dcli outdated` regularly to check version mismatches

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
