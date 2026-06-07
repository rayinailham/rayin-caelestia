#!/usr/bin/env fish

if test "$argv[1]" = '-g'
    set group
    set -e argv[1]
end

if test (count $argv) -ne 2
    echo 'Wrong number of arguments. Usage: ./wsaction.fish [-g] <dispatcher> <workspace>'
    exit 1
end

set -l active_ws (hyprctl activeworkspace -j | jq -r '.id')
set -l target_ws

if set -q group
    # Move to group
    set target_ws (math "($argv[2] - 1) * 10 + $active_ws % 10")
else
    # Move to ws in group
    set target_ws (math "floor(($active_ws - 1) / 10) * 10 + $argv[2]")
end

if test "$argv[1]" = "workspace"
    hyprctl dispatch workspace $target_ws
else if test "$argv[1]" = "movetoworkspace"
    hyprctl dispatch movetoworkspace $target_ws
else
    hyprctl dispatch $argv[1] $target_ws
end
