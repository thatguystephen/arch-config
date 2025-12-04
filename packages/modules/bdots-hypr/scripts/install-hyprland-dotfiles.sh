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
FISH_SOURCE="${MODULE_DIR}/themes-hypr/fish"
KITTY_SOURCE="${MODULE_DIR}/themes-hypr/kitty"
FASTFETCH_SOURCE="${MODULE_DIR}/themes-hypr/fastfetch"
QT5CT_SOURCE="${MODULE_DIR}/themes-hypr/qt5ct"
QT6CT_SOURCE="${MODULE_DIR}/themes-hypr/qt6ct"
GTK3_SOURCE="${MODULE_DIR}/themes-hypr/gtk-3.0"
GTK4_SOURCE="${MODULE_DIR}/themes-hypr/gtk-4.0"

# Target directories
HYPR_TARGET="${CONFIG_DIR}/hypr"
DMS_TARGET="${CONFIG_DIR}/DankMaterialShell"
FISH_TARGET="${CONFIG_DIR}/fish"
KITTY_TARGET="${CONFIG_DIR}/kitty"
FASTFETCH_TARGET="${CONFIG_DIR}/fastfetch"
QT5CT_TARGET="${CONFIG_DIR}/qt5ct"
QT6CT_TARGET="${CONFIG_DIR}/qt6ct"
GTK3_TARGET="${CONFIG_DIR}/gtk-3.0"
GTK4_TARGET="${CONFIG_DIR}/gtk-4.0"

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

# Install Fish shell configuration
install_config "$FISH_SOURCE" "$FISH_TARGET" "Fish shell"

# Install Kitty terminal configuration
install_config "$KITTY_SOURCE" "$KITTY_TARGET" "Kitty terminal"

# Install Fastfetch configuration
install_config "$FASTFETCH_SOURCE" "$FASTFETCH_TARGET" "Fastfetch"

# Install Qt5 configuration
install_config "$QT5CT_SOURCE" "$QT5CT_TARGET" "Qt5ct"

# Install Qt6 configuration
install_config "$QT6CT_SOURCE" "$QT6CT_TARGET" "Qt6ct"

# Install GTK3 configuration
install_config "$GTK3_SOURCE" "$GTK3_TARGET" "GTK3"

# Install GTK4 configuration
install_config "$GTK4_SOURCE" "$GTK4_TARGET" "GTK4"

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



echo -e "${GREEN}Hyprland configuration installed successfully!${NC}"
echo ""
echo -e "${BLUE}Installed configurations:${NC}"
echo "  - Hyprland: $HYPR_TARGET"
if [ -d "$DMS_SOURCE" ]; then
  echo "  - DankMaterialShell: $DMS_TARGET"
fi
if [ -d "$FISH_SOURCE" ]; then
  echo "  - Fish shell: $FISH_TARGET"
fi
if [ -d "$KITTY_SOURCE" ]; then
  echo "  - Kitty: $KITTY_TARGET"
fi
if [ -d "$FASTFETCH_SOURCE" ]; then
  echo "  - Fastfetch: $FASTFETCH_TARGET"
fi
if [ -d "$QT5CT_SOURCE" ]; then
  echo "  - Qt5ct: $QT5CT_TARGET"
fi
if [ -d "$QT6CT_SOURCE" ]; then
  echo "  - Qt6ct: $QT6CT_TARGET"
fi
if [ -d "$GTK3_SOURCE" ]; then
  echo "  - GTK3: $GTK3_TARGET"
fi
if [ -d "$GTK4_SOURCE" ]; then
  echo "  - GTK4: $GTK4_TARGET"
fi
echo ""
echo -e "${BLUE}Note:${NC} To use the new configuration:"
echo "  1. Log out of your current session"
echo "  2. Select 'Hyprland' from your display manager"
echo "  3. Log in to start using Hyprland"
echo ""
echo -e "${YELLOW}Tip:${NC} monitors.conf and workspaces.conf may need adjustment for your specific hardware."
echo ""
