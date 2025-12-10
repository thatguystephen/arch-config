# arch-config - Don's Personal Configuration

> **Note**: This is Don's personal arch-config repository, provided as an **example and reference** for others.
> 
> **For new users**: Do NOT clone this repository directly. Instead:
> 1. Install [dcli](https://gitlab.com/theblackdon/dcli)
> 2. Run `dcli init` to create your own fresh configuration
> 3. Use this repo as a reference for creating your own modules and configurations

This directory contains a declarative package configuration for Arch Linux, inspired by NixOS.

## Directory Structure

```
arch-config/
├── config.yaml              # Pointer to active host configuration
├── hosts/                   # Host-specific configurations
│   ├── don-asus.yaml
│   ├── don-desktop.yaml
│   └── don-deck.yaml
├── modules/                 # Module collections
│   ├── base.yaml           # Core packages (always installed)
│   ├── bdots-hypr/         # Hyprland environment module
│   │   ├── module.yaml
│   │   └── *.yaml          # Package files
│   ├── bdots-niri/         # Niri environment module
│   ├── gaming/             # Gaming packages
│   ├── cli-tools/          # CLI utilities
│   └── package-mods/       # Additional package modules
├── scripts/                 # Post-install hooks and utilities
└── state/                   # Auto-generated tracking files
```

## Quick Start

### 1. Set Active Host

Edit `config.yaml` to point to your host:

```yaml
host: your-hostname
```

### 2. Configure Your Host

Edit `hosts/your-hostname.yaml`:

```yaml
host: your-hostname
description: Your machine configuration

enabled_modules:
  - cli-tools/cli-apps
  - gaming/gaming

packages:
  - firefox
  - discord

exclude: []
auto_prune: false
```

### 3. Add Base Packages

Edit `modules/base.yaml` for packages on all machines:

```yaml
description: Base packages for all machines

packages:
  - base-devel
  - git
  - vim
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

### Package Synchronization

- `dcli sync` - Install packages to match configuration
- `dcli sync -d` or `dcli sync --dry-run` - Preview changes
- `dcli sync --prune` - Remove packages not in configuration
- `dcli sync --force` - Skip confirmation prompts

### Status

- `dcli status` - Show current configuration and sync status

## Creating Modules

### Simple Module

Create `modules/my-module.yaml`:

```yaml
description: Description of what this module provides

packages:
  - package-one
  - package-two

conflicts: []
post_install_hook: ""
```

### Nested Module (Multiple Package Files)

Create `modules/my-module/module.yaml`:

```yaml
description: Multi-file module with submodules

conflicts:
  - conflicting-module

post_install_hook: "scripts/setup.sh"

package_files:
  - packages.yaml
  - optional-packages.yaml
```

Then create `modules/my-module/packages.yaml` with the package list.

## Host Configuration

Hosts are defined in `hosts/<hostname>.yaml` and contain all machine-specific settings:

```yaml
host: my-desktop
description: Desktop configuration

enabled_modules:
  - bdots-hypr
  - gaming/gaming

packages:
  - nvidia-dkms

exclude:
  - tlp

auto_prune: false
backup_tool: snapper
```

The `config.yaml` file at the root is a pointer to the active host:

```yaml
host: my-desktop
```

This allows quick switching between host configurations.

## Module Conflicts

Modules can declare conflicts in their `module.yaml`:

```yaml
conflicts:
  - bdots-kde
  - hyprland
```

dcli will warn if conflicting modules are enabled in a host configuration.

## State Tracking

The `state/installed.yaml` file tracks which packages are managed by dcli. This file is auto-generated and should not be manually edited. It's used to determine which packages are safe to remove with `--prune`.

## Tips

- **Start small**: Begin with `modules/base.yaml` and a simple host config
- **Use dry-run**: Always test with `-d` before syncing
- **Organize modules**: Use nested modules for complex setups (desktop environments, dev tools)
- **Module conflicts**: Declare conflicts to prevent incompatible packages
- **Host pointer**: `config.yaml` just points to active host - all settings in host file

## Example Workflow

```bash
# Initialize
dcli init

# Set active host in config.yaml
echo "host: my-laptop" > ~/.config/arch-config/config.yaml

# Create host configuration
cat > ~/.config/arch-config/hosts/my-laptop.yaml << EOF
host: my-laptop
description: Laptop configuration

enabled_modules:
  - bdots-hypr
  - cli-tools/cli-apps

packages:
  - firefox

exclude: []
auto_prune: false
EOF

# Preview changes
dcli sync -d

# Apply changes
dcli sync

# Check status
dcli status
```

## Troubleshooting

**Module not found**: Check `modules/` directory structure

**Conflicts**: Review module `conflicts` arrays in `module.yaml` files

**YAML errors**: Validate YAML syntax

**State issues**: Delete `state/installed.yaml` to reset tracking

## Advanced: Using with Git

Track your configuration in git:

```bash
cd ~/.config/arch-config
git init
git add config.yaml hosts/ modules/
git commit -m "Initial declarative config"
```

This lets you version control your system configuration and sync it across machines!

---

## Using This Repository as a Reference

This is Don's personal configuration. Here's how to use it as inspiration for your own setup:

### 1. Install dcli

```bash
git clone https://gitlab.com/theblackdon/dcli.git
cd dcli
./install.sh
```

### 2. Create your own configuration

```bash
dcli init  # Creates fresh config at ~/.config/arch-config
```

### 3. Browse this repository for ideas

- **Modules**: Check `modules/` for examples:
  - `bdots-hypr/` - Hyprland desktop environment (nested module)
  - `gaming/` - Gaming packages
  - `cli-tools/` - CLI utilities
  
- **Scripts**: Look at `scripts/` for post-install hooks
- **Host configs**: See `hosts/` for multi-machine setups

### 4. Copy and adapt

Feel free to copy module structures, package lists, or scripts and adapt them to your needs.

### Don's Setup

- **Active host**: don-asus (set in `config.yaml`)
- **Available hosts**: don-asus, don-desktop, don-deck, don-homelab
- **Key modules**: bdots-hypr, bdots-niri, gaming, cli-tools

---

## License

This configuration is provided as-is for reference. Feel free to use and adapt as needed.