#!/bin/bash

WORK_DIR="$HOME/Pictures/Wallpapers/work-wallpapers"
GOON_DIR="$HOME/Pictures/Wallpapers/goon-wallpapers"
STATE_FILE="$HOME/.cache/caelestia/wallpaper_mode.txt"

case "$1" in
    work)
        echo "Switching to Work Mode..."
        "$HOME/.config/hypr/scripts/wallpaper.sh" -r "$WORK_DIR"
        echo "work" > "$STATE_FILE"
        ;;
    goon)
        echo "Switching to Goon Mode..."
        "$HOME/.config/hypr/scripts/wallpaper.sh" -r "$GOON_DIR"
        echo "goon" > "$STATE_FILE"
        ;;
    *)
        echo "Usage: $0 {work|goon}"
        exit 1
        ;;
esac
