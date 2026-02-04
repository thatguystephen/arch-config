#!/bin/bash
# Shell Switching Script for Hyprland
# Switches between Default, Noctalia, DMS, and Ax-Shell with fzf TUI

# Configuration
STATE_FILE="$HOME/.config/hypr/current_shell"
HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_CONF="$HYPR_DIR/hyprland.conf"

# You said your Hyprland setup sources:
#   source = ~/.config/hypr/current_shell_binds.conf
# So we update THIS file to switch binds.
BINDS_FILE="$HYPR_DIR/current_shell_binds.conf"

# IMPORTANT SAFETY NOTE:
# On your system, current_shell_binds.conf was previously a symlink to shell_default.conf.
# If we write to BINDS_FILE while it's still a symlink, we will overwrite shell_default.conf.
# These safeguards ensure BINDS_FILE is always a real file and never clobbers your defaults.

# Default session components:
# - "default": dunst + hyprpaper + EWW windows (but keep EWW daemon alive across modes)
# - "noctalia"/"dms": stop dunst/hyprpaper and close EWW windows (daemon stays up)
# - "ax-shell": stop/keep EWW windows closed, but restart dunst/hyprpaper
DEFAULT_ONLY_KILL_PATTERNS=("dunst" "hyprpaper")

# EWW behavior: do NOT kill the daemon; just close windows when leaving default.
EWW_CLOSE_CMD="eww close-all 2>/dev/null || true"
EWW_DEFAULT_OPEN_CMD="eww daemon >/dev/null 2>&1 || true; sleep 1; eww open-many side-bar"

# Restart commands (guarded to avoid duplicates)
DEFAULT_RESTART_CMD="(pgrep -x dunst >/dev/null || dunst) & (pgrep -x hyprpaper >/dev/null || hyprpaper) & ${EWW_DEFAULT_OPEN_CMD}"
AX_RESTART_CMD="(pgrep -x dunst >/dev/null || dunst) & (pgrep -x hyprpaper >/dev/null || hyprpaper) &"

# Shell configuration (easily extensible for future shells)
declare -A SHELL_START_CMD=(
    ["default"]=""  # default session; no extra shell process
    ["noctalia"]="qs -c noctalia-shell"
    ["dms"]="dms run"
    ["ax-shell"]="uwsm-app python '$HOME/.config/Ax-Shell/main.py'"
)

# Kill patterns for actual shell processes only (not default components)
declare -A SHELL_KILL_PATTERN=(
    ["default"]=""
    ["noctalia"]="qs -c noctalia-shell"
    ["dms"]="dms run"
    ["ax-shell"]="ax-shell"
)

# Bind snippets for each mode. You can adjust these to match your layout.
declare -A SHELL_BINDS_INCLUDE=(
    ["default"]="$HYPR_DIR/shell_default.conf"
    ["noctalia"]="$HYPR_DIR/noctalia/keybinds-noctalia.conf"
    ["dms"]="$HYPR_DIR/dms/binds.conf"
    ["ax-shell"]="$HYPR_DIR/keybinds-ax-shell.conf"
)

declare -A SHELL_DISPLAY_NAME=(
    ["default"]="Default"
    ["noctalia"]="Noctalia"
    ["dms"]="DMS"
    ["ax-shell"]="Ax-Shell"
)

# Function to enable/disable ax-shell.conf sourcing
toggle_axshell_source() {
    local action="$1"  # "enable" or "disable"

    if [ "$action" = "enable" ]; then
        # Uncomment the source line if commented
        sed -i 's|^# *source = ~/.config/Ax-Shell/config/hypr/ax-shell.conf|source = ~/.config/Ax-Shell/config/hypr/ax-shell.conf|' "$HYPRLAND_CONF"
    else
        # Comment out the source line
        sed -i 's|^source = ~/.config/Ax-Shell/config/hypr/ax-shell.conf|# source = ~/.config/Ax-Shell/config/hypr/ax-shell.conf|' "$HYPRLAND_CONF"
    fi
}

# Create state file if it doesn't exist (default to default)
if [ ! -f "$STATE_FILE" ]; then
    echo "default" > "$STATE_FILE"
fi

# Ensure BINDS_FILE is NOT a symlink (otherwise writing to it can overwrite shell_default.conf)
if [ -L "$BINDS_FILE" ]; then
    echo "WARNING: $BINDS_FILE is a symlink. Removing to prevent overwriting shell_default.conf."
    rm -f "$BINDS_FILE"
fi

# Read current shell
CURRENT_SHELL=$(cat "$STATE_FILE")

# Build fzf options list with current shell highlighted
SHELL_OPTIONS=(
    "default"
    "noctalia"
    "dms"
    "ax-shell"
)

# Use fzf to select target shell
TARGET_SHELL=$(printf "%s\n" "${SHELL_OPTIONS[@]}" | \
    fzf --prompt="Select Shell: " \
        --height=40% \
        --border=rounded \
        --reverse \
        --header="Current: ${SHELL_DISPLAY_NAME[$CURRENT_SHELL]}" \
        --color="border:#f5c2e7,header:#cba6f7,prompt:#f5c2e7,pointer:#f5c2e7")

# Exit if no selection made (user pressed ESC)
if [ -z "$TARGET_SHELL" ]; then
    echo "No shell selected. Exiting."
    exit 0
fi

# Exit if same shell selected
if [ "$TARGET_SHELL" = "$CURRENT_SHELL" ]; then
    notify-send "Shell Switcher" "Already using ${SHELL_DISPLAY_NAME[$TARGET_SHELL]}" -t 2000 -u normal
    exit 0
fi

# Get display names
CURRENT_NAME="${SHELL_DISPLAY_NAME[$CURRENT_SHELL]}"
TARGET_NAME="${SHELL_DISPLAY_NAME[$TARGET_SHELL]}"

# Show notification before switching
notify-send "Shell Switcher" "Switching from $CURRENT_NAME to $TARGET_NAME..." -t 2000 -u normal
sleep 2

# Kill current shell process (only if there's a pattern configured)
echo "Killing $CURRENT_NAME shell..."
if [ -n "${SHELL_KILL_PATTERN[$CURRENT_SHELL]}" ]; then
    pkill -f "${SHELL_KILL_PATTERN[$CURRENT_SHELL]}" 2>/dev/null || true
fi
sleep 0.5

# If switching INTO a shell that handles wallpaper/notifications, stop default components
# so they don't conflict, and close EWW windows (do NOT kill daemon).
if [ "$TARGET_SHELL" = "noctalia" ] || [ "$TARGET_SHELL" = "dms" ]; then
    for p in "${DEFAULT_ONLY_KILL_PATTERNS[@]}"; do
        pkill -f "$p" 2>/dev/null || true
    done
    bash -c "$EWW_CLOSE_CMD" >/dev/null 2>&1
fi

# If switching INTO ax-shell, close EWW windows (daemon stays up). Keep/restart dunst+hyprpaper later.
if [ "$TARGET_SHELL" = "ax-shell" ]; then
    bash -c "$EWW_CLOSE_CMD" >/dev/null 2>&1
fi

# Handle Ax-Shell source line toggling
if [ "$TARGET_SHELL" = "ax-shell" ]; then
    echo "Enabling Ax-Shell configuration..."
    toggle_axshell_source "enable"
else
    echo "Disabling Ax-Shell configuration..."
    toggle_axshell_source "disable"
fi

# Update state file
echo "$TARGET_SHELL" > "$STATE_FILE"

# Update Hyprland binds include file to point to new shell's binds
# Your hyprland.conf sources: ~/.config/hypr/current_shell_binds.conf
mkdir -p "$HYPR_DIR"

# Safety: never write through a symlink
if [ -L "$BINDS_FILE" ]; then
    echo "ERROR: $BINDS_FILE is a symlink. Refusing to write to avoid clobbering shell_default.conf."
    exit 1
fi

# Safety: prevent accidental self-referencing
TARGET_BINDS="${SHELL_BINDS_INCLUDE[$TARGET_SHELL]}"
if [ -z "$TARGET_BINDS" ]; then
    echo "ERROR: No binds include configured for shell '$TARGET_SHELL'"
    exit 1
fi

# If the target resolves to the same file, we'd create a recursive include
if [ "$(readlink -f "$TARGET_BINDS" 2>/dev/null || echo "$TARGET_BINDS")" = "$(readlink -f "$BINDS_FILE" 2>/dev/null || echo "$BINDS_FILE")" ]; then
    echo "ERROR: Refusing to set binds to itself ($TARGET_BINDS). Fix SHELL_BINDS_INCLUDE mapping."
    exit 1
fi

echo "source = $TARGET_BINDS" > "$BINDS_FILE"

# Reload Hyprland configuration to apply new keybinds
hyprctl reload

# Start new shell (detached from terminal) unless we're switching to "default"
if [ "$TARGET_SHELL" = "default" ]; then
    echo "Activating default session: restarting dunst/hyprpaper and opening EWW windows..."
    setsid -f bash -c "$DEFAULT_RESTART_CMD" >/dev/null 2>&1
else
    echo "Starting $TARGET_NAME shell..."
    setsid -f bash -c "${SHELL_START_CMD[$TARGET_SHELL]}" >/dev/null 2>&1

    # Ax-Shell: restore notifications + wallpaper, but do NOT open EWW windows.
    if [ "$TARGET_SHELL" = "ax-shell" ]; then
        setsid -f bash -c "$AX_RESTART_CMD" >/dev/null 2>&1
    fi
fi

# Wait for new mode to initialize
sleep 2

# Show completion notification
notify-send "Shell Switcher" "Switched to $TARGET_NAME" -t 2000 -u normal

echo "Successfully switched from $CURRENT_NAME to $TARGET_NAME"

# Wait 1 more second then exit (total 3 seconds)
sleep 1
exit 0
