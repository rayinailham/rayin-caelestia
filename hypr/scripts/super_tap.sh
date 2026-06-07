#!/bin/bash

press_time_file="/tmp/super_press_time"
press_win_file="/tmp/super_press_window"
press_ws_file="/tmp/super_press_workspace"

case "$1" in
    press)
        date +%s%3N > "$press_time_file"
        hyprctl activewindow -j | jq -r '.address' > "$press_win_file" 2>/dev/null || echo "none" > "$press_win_file"
        hyprctl activeworkspace -j | jq -r '.id' > "$press_ws_file" 2>/dev/null || echo "none" > "$press_ws_file"
        ;;
    release)
        press_time=$(cat "$press_time_file" 2>/dev/null || echo 0)
        press_window=$(cat "$press_win_file" 2>/dev/null || echo "none")
        press_workspace=$(cat "$press_ws_file" 2>/dev/null || echo "none")

        now=$(date +%s%3N)
        current_window=$(hyprctl activewindow -j | jq -r '.address' 2>/dev/null || echo "none")
        current_workspace=$(hyprctl activeworkspace -j | jq -r '.id' 2>/dev/null || echo "none")

        time_diff=$((now - press_time))

        if [ $time_diff -lt 200 ] && [ "$press_window" = "$current_window" ] && [ "$press_workspace" = "$current_workspace" ]; then
            hyprctl dispatch global caelestia:launcher
        fi
        ;;
    *)
        echo "Usage: $0 {press|release}"
        exit 1
        ;;
esac
