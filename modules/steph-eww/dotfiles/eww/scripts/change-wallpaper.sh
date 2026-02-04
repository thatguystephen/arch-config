# Get the wallpaper filename passed as an argument
SELECTED_WALLPAPER=$1
WALLPAPER_DIR="$HOME/wallpapers"
ROFI_CONFIG="$HOME/.config/rofi/config-wallpaper.rasi"

MONITOR=$(hyprctl monitors | grep '^Monitor' | awk 'NR==1 {print $2}')

# Ensure the wallpaper file exists
if [ -f "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg" ]; then
 
    SYMLINK_CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
    SYMLINK_LOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"
    TARGET_FILE=$(readlink -f "$SYMLINK_CONFIG_FILE")
    TARGET_FILE2=$(readlink -f "$SYMLINK_LOCK_CONFIG")

    sed -i -e "s|monitor = .*|monitor = $MONITOR|" "$TARGET_FILE"
    sed -i -e "s|path = .*|path = \$HOME/wallpapers/$SELECTED_WALLPAPER.jpg|" "$TARGET_FILE"
    sed -i -e "s|path = .*|path = \$HOME/wallpapers/$SELECTED_WALLPAPER.jpg|" "$TARGET_FILE2"

	# Update rofi config background-image
	if [ -f "$ROFI_CONFIG" ]; then
		sed -i -e "s|background-image:.*url(.*);|background-image: url(\"~/wallpapers/$SELECTED_WALLPAPER.jpg\", width);|" "$ROFI_CONFIG"
		echo "Updated rofi background image to: $SELECTED_WALLPAPER.jpg"
	fi

    ~/zenities/.config/eww/scripts/update-color.sh "$SELECTED_WALLPAPER"
else
    echo "Wallpaper not found: $SELECTED_WALLPAPER"
fi
