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
# Transition tuning (all read natively by awww via these env vars).
# DURATION is the main "speed" knob: bigger = slower/smoother.
_transitions=(fade wave outer grow)
: "${AWWW_TRANSITION:=${_transitions[RANDOM % ${#_transitions[@]}]}}"
: "${AWWW_TRANSITION_STEP:=90}"
: "${AWWW_TRANSITION_FPS:=60}"
: "${AWWW_TRANSITION_DURATION:=1.5}"
if [[ "$AWWW_TRANSITION" == "grow" ]]; then
    : "${AWWW_TRANSITION_POS:=$(awk "BEGIN{srand(); printf \"%.2f,%.2f\", rand(), rand()}")}"
    export AWWW_TRANSITION_POS
fi
export AWWW_TRANSITION AWWW_TRANSITION_STEP AWWW_TRANSITION_FPS AWWW_TRANSITION_DURATION

# Serialize invocations: if a switch is already running (e.g. you spam the
# keybind during a transition), drop this one instead of colliding on the
# awww daemon socket. This debounces rapid presses cleanly.
mkdir -p "$(dirname "$LOCK_FILE")"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

err() { notify-send "Wallpaper" "$1" -i dialog-warning 2>/dev/null || true; echo "$1" >&2; }

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
    ensure_daemon
    # Update the widget theme immediately; awww still animates the wallpaper for 300ms.
    mkdir -p "$(dirname "$CAELESTIA_WALLPAPER_STATE")"
    printf '%s\n' "$file" > "$CAELESTIA_WALLPAPER_STATE"
    caelestia wallpaper -f "$file" >/dev/null 2>&1 || true &
    awww img "$file"
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$file" > "$STATE_FILE"
}

random_from() {
    local dir="$1"
    [ -d "$dir" ] || { err "Not a directory: $dir"; exit 1; }

    # Currently displayed wallpaper (so we can avoid re-picking it).
    local current=""
    [ -s "$STATE_FILE" ] && current=$(cat "$STATE_FILE")

    # Collect all candidate images.
    local -a files=()
    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(find "$dir" -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \) \
        -print0 2>/dev/null)

    [ "${#files[@]}" -gt 0 ] || { err "No images found in $dir"; exit 1; }

    # Drop the current wallpaper from the pool (unless it's the only image),
    # so a random switch always produces a visible change.
    if [ -n "$current" ] && [ "${#files[@]}" -gt 1 ]; then
        local -a filtered=()
        for f in "${files[@]}"; do
            [ "$f" = "$current" ] || filtered+=("$f")
        done
        files=("${filtered[@]}")
    fi

    local file="${files[RANDOM % ${#files[@]}]}"
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
