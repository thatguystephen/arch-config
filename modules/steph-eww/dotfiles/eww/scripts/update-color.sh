#!/bin/bash

# Variables
SELECTED_WALLPAPER=$1
WALLPAPER_DIR="$HOME/wallpapers"
DISCORD_COMBINE_SCRIPT="$HOME/.local/bin/combine-discord-theme.sh"
BROWSER_COLOR_SCRIPT="$HOME/.local/bin/browser-theme.sh"
GTK_COLORS_SOURCE="$HOME/.cache/wal/gtk-colors.css"
GTK_COLORS_DEST="$HOME/.config/gtk-3.0/gtk.css"


# Ensure the wallpaper exists
if [ ! -f "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg" ]; then
	notify-send -u critical "Error: Wallpaper not found: $SELECTED_WALLPAPER"
	exit 1
fi

# Apply pywal colors with fallback
if ! wal -i "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg"; then
    notify-send "Pywal default backend failed, trying 'colorthief'..."
    if ! wal --backend colorthief -i "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg"; then
        notify-send -u critical "Error: All pywal backends failed"
        exit 1
    fi
fi


sleep 1

# Apply Matugen colors
matugen image "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg" || {
	notify-send -u critical "Error: matugen failed"
	exit 1
}

# Update Spicetify theme with pywal colors
if command -v spicetify &>/dev/null; then
    echo "🎵 Updating Spotify theme..."
    
    COMFY_THEME_DIR="$HOME/.config/spicetify/Themes/Comfy"
    mkdir -p "$COMFY_THEME_DIR"
    
    # Copy generated color theme
    if [[ -f "$HOME/.cache/wal/spotify-colors.ini" ]]; then
        cp "$HOME/.cache/wal/spotify-colors.ini" "$COMFY_THEME_DIR/color.ini"
        
        # Apply the theme
        spicetify config current_theme Comfy
        spicetify apply -q
        
        echo "✓ Spotify theme updated"
    else
        echo "⚠ Pywal spicetify template not found"
    fi
fi


# Copy GTK colors to gtk-3.0 folder and rename
if [[ -f "$GTK_COLORS_SOURCE" ]]; then
	mkdir -p "$HOME/.config/gtk-3.0"
	cp "$GTK_COLORS_SOURCE" "$GTK_COLORS_DEST" || notify-send -u critical "Warning: Failed to copy GTK colors"
	echo "GTK colors copied to $GTK_COLORS_DEST"
else
	notify-send -u critical "Warning: GTK colors file not found: $GTK_COLORS_SOURCE"
fi

# Combine Discord theme with pywal colors
if [[ -x "$DISCORD_COMBINE_SCRIPT" ]]; then
	"$DISCORD_COMBINE_SCRIPT" || notify-send -u critical "Warning: Discord theme combination failed"
else
	notify-send -u critical "Warning: Discord combine script not found or not executable: $DISCORD_COMBINE_SCRIPT"
fi

# Update browser colors according to pywal palette
if [[ -x "$BROWSER_COLOR_SCRIPT" ]]; then
  bash "$BROWSER_COLOR_SCRIPT" || notify-send -u critical "Warning: Browser color update script failed"

  sleep 1
else
  notify-send -u critical "Warning: Browser color update script not found or not executable"
fi

# Reload eww
killall eww || notify-send "Warning: No eww process found"
eww open-many side-bar notifications

# Restart hyprpaper
killall hyprpaper || notify-send "Warning: No hyprpaper process found"
hyprpaper &

notify-send "UI Color Theming..." "Completed!"
