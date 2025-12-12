#!/usr/bin/env bash
# Install sysc-greet configuration and setup
# Part of arch-config declarative package management

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running sysc-greet post-install setup...${NC}"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}" >&2
    echo "Usage: sudo $0" >&2
    exit 1
fi

# Run the official sysc-greet install script
echo -e "${BLUE}Fetching and running sysc-greet installer...${NC}"
curl -fsSL https://raw.githubusercontent.com/Nomadcxx/sysc-greet/master/install.sh | bash

echo ""
echo -e "${GREEN}✓ sysc-greet setup completed successfully!${NC}"
echo ""
