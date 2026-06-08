#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$HOME/Pictures/Wallpapers/work-wallpapers"
GOON_DIR="$HOME/Pictures/Wallpapers/goon-wallpapers"
MODE_FILE="$HOME/.cache/caelestia/wallpaper_mode.txt"
CURRENT_FILE="$HOME/.cache/caelestia/current_wallpaper"
CAELESTIA_WALLPAPER_STATE="$HOME/.local/state/caelestia/wallpaper/path.txt"
WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/wallpaper.sh"

in_work_hours() {
    local now
    now="$(date +%H%M)"
    [ "$now" -ge 0830 ] && [ "$now" -lt 1730 ]
}

is_goon_path() {
    case "$1" in
        "$GOON_DIR"|"$GOON_DIR"/*) return 0 ;;
        *) return 1 ;;
    esac
}

current_is_goon() {
    [ -f "$MODE_FILE" ] && [ "$(cat "$MODE_FILE")" = "goon" ] && return 0
    [ -f "$CURRENT_FILE" ] && is_goon_path "$(cat "$CURRENT_FILE")" && return 0
    [ -f "$CAELESTIA_WALLPAPER_STATE" ] && is_goon_path "$(cat "$CAELESTIA_WALLPAPER_STATE")" && return 0
    return 1
}

notify_blocked() {
    notify-send "Wallpaper" "Goon wallpapers are blocked until 17:30." -i dialog-warning 2>/dev/null || true
}

set_work_wallpaper() {
    "$WALLPAPER_SCRIPT" -r "$WORK_DIR"
    mkdir -p "$(dirname "$MODE_FILE")"
    printf '%s\n' work > "$MODE_FILE"
}

enforce_once() {
    if in_work_hours && current_is_goon; then
        notify_blocked
        set_work_wallpaper
    fi
}

case "${1:-}" in
    --can-use-goon)
        ! in_work_hours
        ;;
    --enforce)
        enforce_once
        ;;
    *)
        echo "Usage: $0 {--can-use-goon|--enforce}" >&2
        exit 1
        ;;
esac
