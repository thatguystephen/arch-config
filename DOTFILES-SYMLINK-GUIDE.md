# Dotfiles Symlink System - Guide

## Overview

The `dcli` tool now supports automatic symlinking of dotfiles from your modules to `~/.config/`. This means you can manage your configuration files in your arch-config repository, and `dcli sync` will automatically create symlinks to make them available to your system.

## How It Works

### Symlink Benefits

1. **Bidirectional sync**: Changes in either location automatically reflect in the other
2. **No manual copying**: Files stay in sync automatically
3. **Version control friendly**: Your dotfiles stay in your arch-config repo
4. **One-time backups**: Original files are backed up only once, not on every sync

### Automatic Backup

- The first time `dcli sync` encounters an existing file/directory, it creates a backup
- Backup format: `<name>.backup.YYYYMMDD_HHMMSS`
- Subsequent syncs won't create additional backups
- Backup state is tracked in `/state/dotfiles-state.yaml`

## Module Structure

Only **directory-based modules** can have dotfiles. Legacy single-file modules cannot.

### Directory Layout

```
modules/<module-name>/
├── module.yaml           # Module manifest
├── packages.yaml         # Package definitions
├── dotfiles/            # ← Dotfiles directory (optional)
│   ├── hypr/           # Will symlink to ~/.config/hypr/
│   ├── fish/           # Will symlink to ~/.config/fish/
│   ├── kitty/          # Will symlink to ~/.config/kitty/
│   └── ...             # Any directory here gets symlinked
├── scripts/             # Scripts (not symlinked)
└── other-files/         # Other module files (not symlinked)
```

### What Gets Symlinked

- **Only directories** inside `dotfiles/` are symlinked
- **Each directory** in `dotfiles/` becomes a symlink in `~/.config/`
- **Files** directly in `dotfiles/` are ignored
- **Other module directories** (scripts/, themes/, etc.) are NOT symlinked

### Example

With this structure:
```
modules/bdots-hypr/dotfiles/
├── hypr/
├── fish/
├── kitty/
└── fastfetch/
```

After `dcli sync`, you get:
```
~/.config/hypr/          → symlink to arch-config/packages/modules/bdots-hypr/dotfiles/hypr/
~/.config/fish/          → symlink to arch-config/packages/modules/bdots-hypr/dotfiles/fish/
~/.config/kitty/         → symlink to arch-config/packages/modules/bdots-hypr/dotfiles/kitty/
~/.config/fastfetch/     → symlink to arch-config/packages/modules/bdots-hypr/dotfiles/fastfetch/
```

## Using the System

### Initial Setup

1. **Organize your dotfiles**:
   ```bash
   cd ~/.config/arch-config/packages/modules/<your-module>
   mkdir -p dotfiles
   mv themes-or-configs/* dotfiles/
   ```

2. **Run sync**:
   ```bash
   dcli sync
   ```

3. **Your existing files are backed up** and symlinks are created

### Making Changes

You can edit files in **either location**:

```bash
# Edit in .config (convenient for quick changes)
vim ~/.config/hypr/hyprland.conf

# OR edit in arch-config (better for version control)
vim ~/.config/arch-config/packages/modules/bdots-hypr/dotfiles/hypr/hyprland.conf

# Both are the SAME file - changes appear instantly in both locations!
```

### Syncing Changes

**No sync needed for edits!** The symlink means changes are automatic.

You only need to run `dcli sync` when:
- Enabling/disabling modules
- Adding new dotfile directories
- Installing/removing packages

### Version Control

Since your dotfiles are in arch-config, you can commit them:

```bash
cd ~/.config/arch-config
git add packages/modules/bdots-hypr/dotfiles/
git commit -m "Updated hyprland config"
git push
```

## Pruning

When you disable a module, you can remove its symlinks:

```bash
# Sync with prune enabled
dcli sync --prune

# Or enable auto-prune in config.yaml
auto_prune: true
```

This will:
- Remove symlinks for disabled modules
- Keep the backup files (just in case)
- Update the state file

## Migration Guide

### Migrating from Copy-Based System

If you previously used a post-install hook that copied files:

1. **Move files to dotfiles/ directory**:
   ```bash
   cd ~/.config/arch-config/packages/modules/<module>/
   mkdir -p dotfiles
   mv config-dirs/* dotfiles/
   ```

2. **Update or remove the post-install hook**:
   - Remove file copying logic from your hook script
   - Keep only non-dotfile setup (gsettings, etc.)
   - Or set `hook_behavior: skip` in module.yaml

3. **Run sync**:
   ```bash
   dcli sync
   ```

### Example: bdots-hypr Migration

**Before**:
```
modules/bdots-hypr/
├── themes-hypr/
│   ├── hypr/
│   ├── fish/
│   └── kitty/
├── dotfiles/
│   └── hypr/
└── scripts/install-hyprland-dotfiles.sh  (copies everything)
```

**After**:
```
modules/bdots-hypr/
├── dotfiles/              # All configs here
│   ├── hypr/
│   ├── fish/
│   ├── kitty/
│   ├── DankMaterialShell/
│   └── ...
└── scripts/install-hyprland-dotfiles.sh  (only gsettings/wallpaper)
```

Commands used:
```bash
cd ~/.config/arch-config/packages/modules/bdots-hypr
mv themes-hypr/* dotfiles/
rmdir themes-hypr
# Edit the hook script to remove copying logic
```

## State Files

### dotfiles-state.yaml

Location: `~/.config/arch-config/state/dotfiles-state.yaml`

Tracks which dotfiles have been backed up:

```yaml
backed_up:
  - target: /home/user/.config/hypr
    backup: /home/user/.config/hypr.backup.20231206_120000
    module: bdots-hypr
    backed_up_at: '2023-12-06T12:00:00Z'
```

This ensures backups are only created once.

## Troubleshooting

### Symlink Already Exists

If you manually created symlinks:
```bash
# Remove old symlinks
rm ~/.config/hypr

# Run sync to recreate them properly
dcli sync
```

### Backup Not Created

Check if already backed up:
```bash
cat ~/.config/arch-config/state/dotfiles-state.yaml
```

To force a new backup, remove the entry from the state file.

### Symlink Points to Wrong Location

```bash
# Check where it points
ls -la ~/.config/hypr

# Remove and re-sync
rm ~/.config/hypr
dcli sync
```

### Want to Restore Original Files

Your backups are in `~/.config/`:
```bash
# List backups
ls -la ~/.config/*.backup.*

# Restore (example)
rm ~/.config/hypr  # Remove symlink
mv ~/.config/hypr.backup.20231206_120000 ~/.config/hypr
```

## Best Practices

1. **Keep dotfiles organized**: Group related configs in the same module
2. **Commit frequently**: Your dotfiles are version controlled
3. **Test on fresh system**: The symlinks make it easy to deploy to new machines
4. **Use descriptive module names**: Makes it clear what configs are included
5. **Document module-specific setup**: Add README.md in module directories

## Advanced Usage

### Multiple Machines

Different machines can have different dotfiles:

```
modules/
├── dotfiles-common/
│   └── dotfiles/
│       └── fish/
├── dotfiles-desktop/
│   └── dotfiles/
│       └── hypr/
└── dotfiles-laptop/
    └── dotfiles/
        └── sway/
```

In `config.yaml` on each machine:
```yaml
# Desktop
enabled_modules:
  - dotfiles-common
  - dotfiles-desktop

# Laptop  
enabled_modules:
  - dotfiles-common
  - dotfiles-laptop
```

### Conditional Dotfiles

Use host-specific modules for machine-specific configs:

```
modules/
└── hyprland-multimonitor/
    └── dotfiles/
        └── hypr/
            └── monitors.conf
```

Enable only on machines with multiple monitors.

## Summary

- **Dotfiles in modules**: Put configs in `modules/<name>/dotfiles/<config-name>/`
- **Automatic symlinks**: `dcli sync` creates symlinks to `~/.config/`
- **Bidirectional**: Edit in either location, changes sync automatically
- **One-time backups**: Original files backed up once with timestamp
- **Version controlled**: Your dotfiles stay in your arch-config repo
- **Easy deployment**: Clone arch-config + dcli sync = fully configured system

## See Also

- [Module System Documentation](./MODULES.md) (if it exists)
- [dcli Sync Command](./README.md#sync)
- [Post-Install Hooks](./HOOKS.md) (if it exists)
