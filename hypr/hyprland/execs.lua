local vars = require("variables")

hl.on("hyprland.start", function()
    -- Auth agent
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. vars.cursorTheme .. "'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Resize and move windows based on matches (e.g. pip)
    hl.exec_cmd("caelestia resizer -d")

    -- Wallpaper daemon (awww) + restore last wallpaper
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/wallpaper.sh -R")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")

    -- Warm special-workspace apps so overlay keybinds open faster
    hl.exec_cmd("~/.config/hypr/scripts/warm-special-apps.sh")
end)
