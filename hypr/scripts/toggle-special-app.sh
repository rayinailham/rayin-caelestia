#!/usr/bin/env bash
set -euo pipefail

name="${1:?missing name}"
class_re="${2:?missing class regex}"
shift 2

case "$name" in
    browser) hyprctl keyword animation "specialWorkspace, 1, 3, specialWorkSwitch, slidefade -25%" >/dev/null ;;
    music) hyprctl keyword animation "specialWorkspace, 1, 3, specialWorkSwitch, slidefadevert -25%" >/dev/null ;;
    whatsapp) hyprctl keyword animation "specialWorkspace, 1, 3, specialWorkSwitch, slidefade 25%" >/dev/null ;;
    communication) hyprctl keyword animation "specialWorkspace, 1, 3, specialWorkSwitch, slidefade -25%" >/dev/null ;;
    github) hyprctl keyword animation "specialWorkspace, 1, 3, specialWorkSwitch, fade" >/dev/null ;;
esac

if hyprctl clients -j | jq -e --arg re "$class_re" 'any(.[]; (.class // "") | test($re; "i"))' >/dev/null; then
    hyprctl dispatch togglespecialworkspace "$name" >/dev/null
else
    hyprctl dispatch exec "$*" >/dev/null
fi
