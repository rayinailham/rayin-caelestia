#!/usr/bin/env bash
# Wallpaper wrapper: awww displays the image, caelestia generates the colour scheme.
#
# Usage:
#   wallpaper.sh -f /path/to/image.png     # set a specific wallpaper
#   wallpaper.sh -r /path/to/dir           # pick a random wallpaper from a dir
#   wallpaper.sh -R                        # restore last wallpaper (e.g. on startup)
#
# Transitions can be tuned with env vars (read natively by awww):
#   AWWW_TRANSITION, AWWW_TRANSITION_STEP, AWWW_TRANSITION_FPS
set -euo pipefail

STATE_FILE="$HOME/.cache/caelestia/current_wallpaper"
CAELESTIA_WALLPAPER_STATE="$HOME/.local/state/caelestia/wallpaper/path.txt"
LOCK_FILE="$HOME/.cache/caelestia/wallpaper.lock"
WORK_DIR="$HOME/Pictures/Wallpapers/work-wallpapers"
GOON_DIR="$HOME/Pictures/Wallpapers/goon-wallpapers"
# Transition tuning (all read natively by awww via these env vars).
# DURATION is the main "speed" knob: bigger = slower/smoother.
: "${AWWW_TRANSITION:=grow}"
: "${AWWW_TRANSITION_STEP:=90}"
: "${AWWW_TRANSITION_FPS:=60}"
: "${AWWW_TRANSITION_DURATION:=1.5}"
_POS_STATE="$HOME/.cache/caelestia/grow_pos"
_MIN_DIST=0.3
_gen_pos() {
    local last_x=0 last_y=0
    if [ -f "$_POS_STATE" ]; then
        IFS=',' read -r last_x last_y < "$_POS_STATE"
    fi
    awk -v lx="$last_x" -v ly="$last_y" -v min="$_MIN_DIST" '
    BEGIN {
        srand()
        do {
            x = rand()
            y = rand()
            dx = x - lx
            dy = y - ly
            dist = sqrt(dx*dx + dy*dy)
        } while (dist < min)
        printf "%.2f,%.2f", x, y
    }'
}
: "${AWWW_TRANSITION_POS:=$(_gen_pos)}"
printf '%s\n' "$AWWW_TRANSITION_POS" > "$_POS_STATE"
export AWWW_TRANSITION AWWW_TRANSITION_STEP AWWW_TRANSITION_FPS AWWW_TRANSITION_DURATION AWWW_TRANSITION_POS

# Serialize invocations: if a switch is already running (e.g. you spam the
# keybind during a transition), drop this one instead of colliding on the
# awww daemon socket. This debounces rapid presses cleanly.
mkdir -p "$(dirname "$LOCK_FILE")"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

err() { notify-send "Wallpaper" "$1" -i dialog-warning 2>/dev/null || true; echo "$1" >&2; }

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

# Ensure the daemon is up before issuing commands.
ensure_daemon() {
    if ! awww query >/dev/null 2>&1; then
        awww-daemon &
        # Wait until the daemon is ready (max ~3s).
        for _ in $(seq 1 30); do
            awww query >/dev/null 2>&1 && return 0
            sleep 0.1
        done
        err "awww-daemon did not start"
        exit 1
    fi
}

# Display an image with awww and regenerate the colour scheme with caelestia.
apply() {
    local file="$1"
    [ -f "$file" ] || { err "Not a file: $file"; exit 1; }
    if in_work_hours && is_goon_path "$file"; then
        err "Goon wallpapers are blocked until 17:30; switching to work wallpapers."
        random_from "$WORK_DIR"
        return
    fi
    ensure_daemon
    # Update the widget theme immediately; awww still animates the wallpaper for 300ms.
    mkdir -p "$(dirname "$CAELESTIA_WALLPAPER_STATE")"
    printf '%s\n' "$file" > "$CAELESTIA_WALLPAPER_STATE"
    caelestia wallpaper -f "$file" >/dev/null 2>&1 || true &
    awww img "$file"
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$file" > "$STATE_FILE"
}

_COOLDOWN_FILE="$HOME/.cache/caelestia/wallpaper_cooldown"
_COOLDOWN_TURNS=5

_load_cooldowns() {
    declare -gA _cooldowns=()
    [ -f "$_COOLDOWN_FILE" ] || return 0
    while IFS=$'\t' read -r count path; do
        _cooldowns["$path"]="$count"
    done < "$_COOLDOWN_FILE"
}

_tick_cooldowns() {
    local -a to_remove=()
    for path in "${!_cooldowns[@]}"; do
        _cooldowns["$path"]=$(( ${_cooldowns["$path"]} - 1 ))
        [ "${_cooldowns["$path"]}" -le 0 ] && to_remove+=("$path")
    done
    for path in "${to_remove[@]}"; do
        unset '_cooldowns["$path"]'
    done
}

_save_cooldowns() {
    mkdir -p "$(dirname "$_COOLDOWN_FILE")"
    : > "$_COOLDOWN_FILE"
    for path in "${!_cooldowns[@]}"; do
        printf '%s\t%s\n' "${_cooldowns["$path"]}" "$path" >> "$_COOLDOWN_FILE"
    done
}

random_from() {
    local dir="$1"
    [ -d "$dir" ] || { err "Not a directory: $dir"; exit 1; }
    if in_work_hours && is_goon_path "$dir"; then
        err "Goon wallpapers are blocked until 17:30; switching to work wallpapers."
        dir="$WORK_DIR"
        [ -d "$dir" ] || { err "Not a directory: $dir"; exit 1; }
    fi

    _load_cooldowns
    _tick_cooldowns

    local -a files=()
    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(find "$dir" -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \) \
        -print0 2>/dev/null)

    [ "${#files[@]}" -gt 0 ] || { err "No images found in $dir"; exit 1; }

    local -a eligible=()
    for f in "${files[@]}"; do
        [ -z "${_cooldowns["$f"]+x}" ] && eligible+=("$f")
    done

    if [ "${#eligible[@]}" -eq 0 ]; then
        eligible=("${files[@]}")
    fi

    local file="${eligible[RANDOM % ${#eligible[@]}]}"
    _cooldowns["$file"]="$_COOLDOWN_TURNS"
    _save_cooldowns
    apply "$file"
}

case "${1:-}" in
    -f|--file)   apply "${2:?missing file path}" ;;
    -r|--random) random_from "${2:?missing directory}" ;;
    -R|--restore)
        if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
            apply "$(cat "$STATE_FILE")"
        else
            err "No saved wallpaper to restore"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {-f FILE | -r DIR | -R}" >&2
        exit 1
        ;;
esac
