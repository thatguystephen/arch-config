#!/bin/bash
# Shell Switching Script for Hyprland
# Switches between DMS and Noctalia shells with proper process management

# Configuration
STATE_FILE="$HOME/.config/hypr/current_shell"
HYPR_DIR="$HOME/.config/hypr"
SYMLINK="$HYPR_DIR/keybinds-active.conf"

# Shell configuration (easily extensible for future shells)
declare -A SHELL_START_CMD=(
    ["noctalia"]="qs -c noctalia-shell"
    ["dms"]="dms run"
)

declare -A SHELL_KILL_PATTERN=(
    ["noctalia"]="qs -c noctalia-shell"
    ["dms"]="dms run"
)

declare -A SHELL_KEYBIND_FILE=(
    ["noctalia"]="$HYPR_DIR/keybinds-noctalia.conf"
    ["dms"]="$HYPR_DIR/keybinds-dms.conf"
)

declare -A SHELL_DISPLAY_NAME=(
    ["noctalia"]="Noctalia"
    ["dms"]="DMS"
)

declare -A SHELL_NOTIFY_CMD=(
    ["noctalia"]="qs -c noctalia-shell ipc call notifications send"
    ["dms"]="dms ipc call notifications send"
)

# Create state file if it doesn't exist (default to noctalia)
if [ ! -f "$STATE_FILE" ]; then
    echo "noctalia" > "$STATE_FILE"
fi

# Read current shell
CURRENT_SHELL=$(cat "$STATE_FILE")

# Determine target shell (switch to the opposite)
if [ "$CURRENT_SHELL" = "noctalia" ]; then
    TARGET_SHELL="dms"
elif [ "$CURRENT_SHELL" = "dms" ]; then
    TARGET_SHELL="noctalia"
else
    # Default to noctalia if state is corrupted
    TARGET_SHELL="noctalia"
    echo "noctalia" > "$STATE_FILE"
fi

# Get display names
CURRENT_NAME="${SHELL_DISPLAY_NAME[$CURRENT_SHELL]}"
TARGET_NAME="${SHELL_DISPLAY_NAME[$TARGET_SHELL]}"

# Show notification using current shell before killing it
notify-send "Shell Switcher" "Switching to $TARGET_NAME..." -t 2000 -u normal

# Wait 2 seconds so notification is visible BEFORE killing the shell
sleep 2

# Kill current shell process
echo "Killing $CURRENT_NAME shell..."
pkill -f "${SHELL_KILL_PATTERN[$CURRENT_SHELL]}" 2>/dev/null
sleep 0.5

# Update state file
echo "$TARGET_SHELL" > "$STATE_FILE"

# Update symlink to point to new shell's keybind file
ln -sf "${SHELL_KEYBIND_FILE[$TARGET_SHELL]}" "$SYMLINK"

# Reload Hyprland configuration to apply new keybinds
hyprctl reload

# Start new shell
echo "Starting $TARGET_NAME shell..."
${SHELL_START_CMD[$TARGET_SHELL]} &

# Wait for new shell to fully initialize (important for notification daemon to be ready)
sleep 2

# Show completion notification - new shell's notification daemon should handle it now
notify-send "Shell Switcher" "Switched to $TARGET_NAME" -t 2000 -u normal

echo "Successfully switched from $CURRENT_NAME to $TARGET_NAME"
