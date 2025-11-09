#!/usr/bin/env bash
# Install LazyVim Neovim distribution
# Part of arch-config declarative package management

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the actual user (not root if run with sudo)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

NVIM_CONFIG_DIR="${ACTUAL_HOME}/.config/nvim"
NVIM_DATA_DIR="${ACTUAL_HOME}/.local/share/nvim"
NVIM_STATE_DIR="${ACTUAL_HOME}/.local/state/nvim"
NVIM_CACHE_DIR="${ACTUAL_HOME}/.cache/nvim"
LAZYVIM_STARTER="https://github.com/LazyVim/starter"

echo -e "${BLUE}Installing LazyVim Neovim distribution...${NC}"
echo ""

# Check Neovim version
echo -e "${BLUE}Checking Neovim version...${NC}"
if ! command -v nvim &> /dev/null; then
  echo -e "${RED}Error: Neovim is not installed${NC}" >&2
  exit 1
fi

NVIM_VERSION=$(nvim --version | head -n 1 | grep -oP 'NVIM v\K[0-9.]+' || echo "0.0.0")
REQUIRED_VERSION="0.11.2"

# Simple version comparison (assumes format X.Y.Z)
version_compare() {
  local IFS=.
  local i ver1=($1) ver2=($2)
  for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
    if [[ ${ver1[i]:-0} -lt ${ver2[i]:-0} ]]; then
      return 1
    elif [[ ${ver1[i]:-0} -gt ${ver2[i]:-0} ]]; then
      return 0
    fi
  done
  return 0
}

if ! version_compare "$NVIM_VERSION" "$REQUIRED_VERSION"; then
  echo -e "${YELLOW}Warning: Neovim version $NVIM_VERSION is older than required $REQUIRED_VERSION${NC}"
  echo -e "${YELLOW}LazyVim may not work correctly. Consider upgrading Neovim.${NC}"
  echo ""
fi

# Backup existing Neovim configuration
BACKUP_SUFFIX=".bak-$(date +%Y%m%d-%H%M%S)"

if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR" ]; then
  echo -e "${YELLOW}Backing up existing Neovim configuration...${NC}"
  BACKUP_CONFIG="${NVIM_CONFIG_DIR}${BACKUP_SUFFIX}"
  sudo -u "$ACTUAL_USER" mv "$NVIM_CONFIG_DIR" "$BACKUP_CONFIG"
  echo -e "${GREEN}✓ Backed up to: $BACKUP_CONFIG${NC}"
fi

if [ -d "$NVIM_DATA_DIR" ]; then
  echo -e "${YELLOW}Backing up Neovim data directory...${NC}"
  BACKUP_DATA="${NVIM_DATA_DIR}${BACKUP_SUFFIX}"
  sudo -u "$ACTUAL_USER" mv "$NVIM_DATA_DIR" "$BACKUP_DATA"
  echo -e "${GREEN}✓ Backed up to: $BACKUP_DATA${NC}"
fi

if [ -d "$NVIM_STATE_DIR" ]; then
  echo -e "${YELLOW}Backing up Neovim state directory...${NC}"
  BACKUP_STATE="${NVIM_STATE_DIR}${BACKUP_SUFFIX}"
  sudo -u "$ACTUAL_USER" mv "$NVIM_STATE_DIR" "$BACKUP_STATE"
  echo -e "${GREEN}✓ Backed up to: $BACKUP_STATE${NC}"
fi

if [ -d "$NVIM_CACHE_DIR" ]; then
  echo -e "${YELLOW}Backing up Neovim cache directory...${NC}"
  BACKUP_CACHE="${NVIM_CACHE_DIR}${BACKUP_SUFFIX}"
  sudo -u "$ACTUAL_USER" mv "$NVIM_CACHE_DIR" "$BACKUP_CACHE"
  echo -e "${GREEN}✓ Backed up to: $BACKUP_CACHE${NC}"
fi

echo ""

# Clone LazyVim starter
echo -e "${BLUE}Cloning LazyVim starter repository...${NC}"
if ! sudo -u "$ACTUAL_USER" git clone "$LAZYVIM_STARTER" "$NVIM_CONFIG_DIR"; then
  echo -e "${RED}Error: Failed to clone LazyVim starter${NC}" >&2
  exit 1
fi

# Remove .git folder from starter
echo -e "${BLUE}Removing .git folder from starter...${NC}"
rm -rf "${NVIM_CONFIG_DIR}/.git"

# Set proper ownership
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$NVIM_CONFIG_DIR"

echo ""
echo -e "${GREEN}✓ LazyVim installed successfully!${NC}"
echo ""
echo -e "${BLUE}Installation location:${NC}"
echo "  $NVIM_CONFIG_DIR"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Launch Neovim with: ${YELLOW}nvim${NC}"
echo "  2. LazyVim will automatically install plugins on first launch"
echo "  3. After plugins install, run: ${YELLOW}:LazyHealth${NC}"
echo "  4. Check that everything is working correctly"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  Customize LazyVim by editing files in:"
echo "  ${NVIM_CONFIG_DIR}/lua/config/"
echo "  ${NVIM_CONFIG_DIR}/lua/plugins/"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  https://www.lazyvim.org/"
echo ""
