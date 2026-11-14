#!/usr/bin/env bash
set -euo pipefail

name="${1:?missing name}"
class_re="${2:?missing class regex}"
shift 2

case "$name" in
    browser) hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "slidefade -25%" })' >/dev/null ;;
    music) hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "slidefadevert -25%" })' >/dev/null ;;
    whatsapp) hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "slidefade 25%" })' >/dev/null ;;
    communication) hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "slidefade -25%" })' >/dev/null ;;
    github) hyprctl eval 'hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "fade" })' >/dev/null ;;
esac

if hyprctl clients -j | jq -e --arg re "$class_re" 'any(.[]; (.class // "") | test($re; "i"))' >/dev/null; then
    hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$name\")" >/dev/null
else
    hyprctl dispatch "hl.dsp.exec_cmd([==[$*]==])" >/dev/null
fi
