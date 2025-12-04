#!/usr/bin/env bash
# Install Hyprland configuration
# Part of arch-config declarative package management

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine the user (handles both sudo and non-sudo cases)
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="/home/${TARGET_USER}"
CONFIG_DIR="${TARGET_HOME}/.config"
ARCH_CONFIG_DIR="${ARCH_CONFIG_DIR:-${TARGET_HOME}/.config/arch-config}"

# Module directory (relative to ARCH_CONFIG_DIR)
MODULE_DIR="${ARCH_CONFIG_DIR}/packages/modules/bdots-hypr"

# Source directories
HYPR_SOURCE="${MODULE_DIR}/dotfiles/hypr"
DMS_SOURCE="${MODULE_DIR}/themes-hypr/DankMaterialShell"

# Target directories
HYPR_TARGET="${CONFIG_DIR}/hypr"
DMS_TARGET="${CONFIG_DIR}/DankMaterialShell"

# Backup suffix
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}Installing Hyprland configuration...${NC}"
echo ""

# Check if source directories exist
if [ ! -d "$HYPR_SOURCE" ]; then
  echo -e "${RED}Error: Hyprland source directory not found: $HYPR_SOURCE${NC}" >&2
  exit 1
fi

# Create .config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${YELLOW}Creating config directory: $CONFIG_DIR${NC}"
  mkdir -p "$CONFIG_DIR"
  chown "$TARGET_USER:$TARGET_USER" "$CONFIG_DIR"
fi

# Function to backup and copy config
install_config() {
  local source="$1"
  local target="$2"
  local name="$3"

  if [ ! -d "$source" ]; then
    echo -e "${YELLOW}Skipping $name (source not found)${NC}"
    return
  fi

  # Backup existing configuration if it exists
  if [ -d "$target" ]; then
    local backup="${target}${BACKUP_SUFFIX}"
    echo -e "${YELLOW}Backing up existing $name configuration...${NC}"
    echo -e "${BLUE}  From: $target${NC}"
    echo -e "${BLUE}  To:   $backup${NC}"

    if [ "$EUID" -eq 0 ]; then
      sudo -u "$TARGET_USER" cp -r "$target" "$backup"
    else
      cp -r "$target" "$backup"
    fi
    echo -e "${GREEN}Backup created${NC}"
    echo ""

    # Remove existing config
    rm -rf "$target"
  fi

  # Copy configuration
  echo -e "${BLUE}Installing $name configuration...${NC}"
  echo -e "${BLUE}  From: $source${NC}"
  echo -e "${BLUE}  To:   $target${NC}"

  if [ "$EUID" -eq 0 ]; then
    sudo -u "$TARGET_USER" cp -r "$source" "$target"
    chown -R "$TARGET_USER:$TARGET_USER" "$target"
  else
    cp -r "$source" "$target"
  fi

  echo -e "${GREEN}$name installed${NC}"
  echo ""
}

# Install Hyprland configuration
install_config "$HYPR_SOURCE" "$HYPR_TARGET" "Hyprland"

# Install DankMaterialShell configuration (shared theme)
install_config "$DMS_SOURCE" "$DMS_TARGET" "DankMaterialShell"

# Create keybinds-active.conf symlink
echo -e "${BLUE}Creating keybinds-active.conf symlink...${NC}"
if [ -f "${HYPR_TARGET}/keybinds-dms.conf" ]; then
  ln -sf "${HYPR_TARGET}/keybinds-dms.conf" "${HYPR_TARGET}/keybinds-active.conf"
  if [ "$EUID" -eq 0 ]; then
    chown -h "$TARGET_USER:$TARGET_USER" "${HYPR_TARGET}/keybinds-active.conf"
  fi
  echo -e "${GREEN}Symlink created: keybinds-active.conf -> keybinds-dms.conf${NC}"
  echo ""
fi

# Apply GTK theming
echo -e "${BLUE}Applying GTK theme configuration...${NC}"

GTK3_SETTINGS="${CONFIG_DIR}/gtk-3.0/settings.ini"
GTK4_SETTINGS="${CONFIG_DIR}/gtk-4.0/settings.ini"

# Create GTK config directories
mkdir -p "${CONFIG_DIR}/gtk-3.0"
mkdir -p "${CONFIG_DIR}/gtk-4.0"

if [ "$EUID" -eq 0 ]; then
  chown "$TARGET_USER:$TARGET_USER" "${CONFIG_DIR}/gtk-3.0"
  chown "$TARGET_USER:$TARGET_USER" "${CONFIG_DIR}/gtk-4.0"
fi

# GTK3 settings
cat > "$GTK3_SETTINGS" << 'EOF'
[Settings]
gtk-theme-name=catppuccin-mocha-mauve-standard+default
gtk-icon-theme-name=Tela-purple
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

if [ "$EUID" -eq 0 ]; then
  chown "$TARGET_USER:$TARGET_USER" "$GTK3_SETTINGS"
fi

# GTK4 settings
cat > "$GTK4_SETTINGS" << 'EOF'
[Settings]
gtk-theme-name=catppuccin-mocha-mauve-standard+default
gtk-icon-theme-name=Tela-purple
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

if [ "$EUID" -eq 0 ]; then
  chown "$TARGET_USER:$TARGET_USER" "$GTK4_SETTINGS"
fi

echo -e "${GREEN}GTK theme configured:${NC}"
echo "  - Theme: catppuccin-mocha-mauve-standard+default"
echo "  - Icons: Tela-purple"
echo ""

echo -e "${GREEN}Hyprland configuration installed successfully!${NC}"
echo ""
echo -e "${BLUE}Installed:${NC}"
echo "  - $HYPR_TARGET"
if [ -d "$DMS_SOURCE" ]; then
  echo "  - $DMS_TARGET"
fi
echo "  - GTK3 theme: $GTK3_SETTINGS"
echo "  - GTK4 theme: $GTK4_SETTINGS"
echo ""
echo -e "${BLUE}Note:${NC} To use the new configuration:"
echo "  1. Log out of your current session"
echo "  2. Select 'Hyprland' from your display manager"
echo "  3. Log in to start using Hyprland"
echo ""
echo -e "${YELLOW}Tip:${NC} monitors.conf and workspaces.conf may need adjustment for your specific hardware."
echo ""
