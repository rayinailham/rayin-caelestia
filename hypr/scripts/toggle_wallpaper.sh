#!/bin/bash

# Configuration Paths
SHELL_CONFIG="$HOME/.config/caelestia/shell.json"
WORK_DIR="$HOME/Pictures/work-wallpapers"
GOON_DIR="$HOME/Pictures/goon-wallpapers"
STATE_FILE="$HOME/.cache/caelestia/wallpaper_mode.txt"

# Default Steam Wallpaper Engine Path or ID (update this with your workshop path/ID)
# Example: "$HOME/.steam/steam/steamapps/workshop/content/431960/123456789"
STEAM_WALLPAPER_PATH="" 

# Find monitor name (first active monitor in Hyprland)
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

toggle_caelestia_wallpaper() {
    local enabled=$1
    if [ -f "$SHELL_CONFIG" ]; then
        jq --argjson val "$enabled" '.background.wallpaperEnabled = $val' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp" && mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
    else
        mkdir -p "$(dirname "$SHELL_CONFIG")"
        echo "{\"background\": {\"wallpaperEnabled\": $enabled}}" > "$SHELL_CONFIG"
    fi
}

case "$1" in
    work)
        echo "Switching to Work Mode..."
        pkill -f linux-wallpaperengine
        toggle_caelestia_wallpaper true
        caelestia wallpaper -n -r "$WORK_DIR"
        echo "work" > "$STATE_FILE"
        ;;
    goon)
        echo "Switching to Goon Mode..."
        pkill -f linux-wallpaperengine
        toggle_caelestia_wallpaper true
        caelestia wallpaper -n -r "$GOON_DIR"
        echo "goon" > "$STATE_FILE"
        ;;
    steam)
        echo "Switching to Steam Wallpaper Engine..."
        pkill -f linux-wallpaperengine
        
        # Check if steam wallpaper path is configured
        if [ -z "$STEAM_WALLPAPER_PATH" ]; then
            notify-send "Wallpaper Mode" "Steam Wallpaper Path is not set in script!" -i dialog-warning
            exit 1
        fi
        
        toggle_caelestia_wallpaper false
        linux-wallpaperengine --screen-root "$MONITOR" --silent "$STEAM_WALLPAPER_PATH" &
        echo "steam" > "$STATE_FILE"
        ;;
    *)
        echo "Usage: $0 {work|goon|steam}"
        exit 1
        ;;
esac
