-- Ported 1:1 from keybinds.conf (Hyprland 0.57 dropped hyprlang, 2026-11-14)
-- Every bind carries a description: shortcut_help.py (Super + /) reads them live via `hyprctl binds -j`.
local vars = require("variables")
local fn   = require("utils.functions")

local dsp  = hl.dsp

-- Flags (legacy bind suffixes)
local l    = { locked = true }                   -- bindl
local e    = { repeating = true }                -- binde
local le   = { locked = true, repeating = true } -- bindle
local r    = { release = true }                  -- bindr
local m    = { mouse = true }                    -- bindm

local function bind(key, action, flags, desc)
    local opts = {}
    for k, v in pairs(flags or {}) do opts[k] = v end
    opts.description = desc
    hl.bind(key, action, opts)
end
local function exec(cmd) return dsp.exec_cmd(cmd) end
local function global(name) return dsp.global("caelestia:" .. name) end

-- ## Shell keybinds
-- Launcher (tap Super)
bind("Super_L", exec("~/.config/hypr/scripts/super_tap.sh press"), { non_consuming = true })
bind("SUPER + Super_L", exec("~/.config/hypr/scripts/super_tap.sh release"), { release = true, non_consuming = true },
    "Open app launcher (tap)")

-- Misc
bind(vars.kbSession, global("session"), nil, "Session menu")
bind(vars.kbShowSidebar, global("sidebar"), nil, "Toggle sidebar")
bind(vars.kbClearNotifs, global("clearNotifs"), l, "Clear notifications")
bind(vars.kbShowPanels, global("dashboard"), nil, "Toggle dashboard")
bind(vars.kbLock, global("lock"), nil, "Lock screen")

-- Restore lock
bind(vars.kbRestoreLock, function()
    hl.dispatch(exec("caelestia shell -d"))
    hl.dispatch(global("lock"))
end, l, "Restore lock screen")

-- Shell refreshes devices on lock-key toggles (was a runtime `keyword` from the shell)
bind("Caps_Lock", global("refreshDevices"), { locked = true, non_consuming = true, ignore_mods = true })
bind("Num_Lock", global("refreshDevices"), { locked = true, non_consuming = true, ignore_mods = true })

-- Brightness
bind("XF86MonBrightnessUp", global("brightnessUp"), l, "Brightness up")
bind("XF86MonBrightnessDown", global("brightnessDown"), l, "Brightness down")

-- Media
for _, k in ipairs({ "CTRL + SUPER + Space", "XF86AudioPlay", "XF86AudioPause" }) do bind(k, global("mediaToggle"), l, "Media play/pause") end
for _, k in ipairs({ "CTRL + SUPER + Equal", "XF86AudioNext" }) do bind(k, global("mediaNext"), l, "Media next") end
for _, k in ipairs({ "CTRL + SUPER + Minus", "XF86AudioPrev" }) do bind(k, global("mediaPrev"), l, "Media previous") end
bind("XF86AudioStop", global("mediaStop"), l, "Media stop")

-- Kill/restart shell (Ctrl+Super+Shift+R is in hypr-user.lua)
bind("CTRL + SUPER + ALT + R", exec("caelestia shell -k; sleep .1; caelestia shell -d"), r, "Restart shell UI")

-- Go to / move window to workspace # and workspace group #
for i = 1, 10 do
    local key = tostring(i % 10) -- 10 maps to key 0
    bind(vars.kbGoToWs .. " + " .. key, fn.wsaction("focus", "", i), nil, "Go to workspace " .. i)
    bind(vars.kbGoToWsGroup .. " + " .. key, fn.wsaction("focus", "group", i), nil, "Go to workspace group " .. i)
    bind(vars.kbMoveWinToWs .. " + " .. key, fn.wsaction("move", "", i), nil, "Move window to workspace " .. i)
    bind(vars.kbMoveWinToWsGroup .. " + " .. key, fn.wsaction("move", "group", i), nil, "Move window to workspace group " .. i)
end

-- Go to workspace -1/+1
bind("SUPER + mouse_down", dsp.focus({ workspace = "-1" }), nil, "Previous workspace")
bind("SUPER + mouse_up", dsp.focus({ workspace = "+1" }), nil, "Next workspace")
bind(vars.kbPrevWs, dsp.focus({ workspace = "-1" }), e, "Previous workspace")
bind(vars.kbNextWs, dsp.focus({ workspace = "+1" }), e, "Next workspace")
bind("SUPER + Page_Up", dsp.focus({ workspace = "-1" }), e, "Previous workspace")
bind("SUPER + Page_Down", dsp.focus({ workspace = "+1" }), e, "Next workspace")

-- Go to workspace group -1/+1
bind("CTRL + SUPER + mouse_down", dsp.focus({ workspace = "-10" }), nil, "Previous workspace group")
bind("CTRL + SUPER + mouse_up", dsp.focus({ workspace = "+10" }), nil, "Next workspace group")

-- Toggle special workspace
bind(vars.kbToggleSpecialWs, dsp.workspace.toggle_special("special"), nil, "Toggle special workspace")

-- Move window to workspace -1/+1
bind("SUPER + ALT + Page_Up", dsp.window.move({ workspace = "-1" }), e, "Move window to previous workspace")
bind("SUPER + ALT + Page_Down", dsp.window.move({ workspace = "+1" }), e, "Move window to next workspace")
bind("SUPER + ALT + mouse_down", dsp.window.move({ workspace = "-1" }), nil, "Move window to previous workspace")
bind("SUPER + ALT + mouse_up", dsp.window.move({ workspace = "+1" }), nil, "Move window to next workspace")
bind("CTRL + SUPER + SHIFT + right", dsp.window.move({ workspace = "+1" }), e, "Move window to next workspace")
bind("CTRL + SUPER + SHIFT + left", dsp.window.move({ workspace = "-1" }), e, "Move window to previous workspace")

-- Move window to/from special workspace
bind("CTRL + SUPER + SHIFT + up", dsp.window.move({ workspace = "special:special" }), nil, "Move window to special workspace")
bind("CTRL + SUPER + SHIFT + down", dsp.window.move({ workspace = "e+0" }), nil, "Move window out of special workspace")
bind("SUPER + ALT + S", dsp.window.move({ workspace = "special:special" }), nil, "Move window to special workspace")

-- Window groups
bind(vars.kbWindowGroupCycleNext, dsp.window.cycle_next(), e, "Cycle windows")
bind(vars.kbWindowGroupCyclePrev, dsp.window.cycle_next({ next = false }), e, "Cycle windows backward")
bind("CTRL + ALT + Tab", dsp.group.next(), e, "Window group: next tab")
bind("CTRL + SHIFT + ALT + Tab", dsp.group.prev(), e, "Window group: previous tab")
bind(vars.kbToggleGroup, dsp.group.toggle(), nil, "Window group: toggle")
bind(vars.kbUngroup, dsp.window.move({ out_of_group = true }), nil, "Window group: ungroup window")
bind("SUPER + SHIFT + Comma", dsp.group.lock(), nil, "Window group: toggle lock")

-- Window actions
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind("SUPER + " .. dir, dsp.focus({ direction = dir }), nil, "Focus window " .. dir)
    bind("SUPER + SHIFT + " .. dir, dsp.window.move({ direction = dir }), nil, "Move window " .. dir)
end
bind("SUPER + Minus", fn.resize_active_window(-10, 0), e, "Resize window narrower")
bind("SUPER + Equal", fn.resize_active_window(10, 0), e, "Resize window wider")
bind("SUPER + SHIFT + Minus", fn.resize_active_window(0, -10), e, "Resize window shorter")
bind("SUPER + SHIFT + Equal", fn.resize_active_window(0, 10), e, "Resize window taller")
bind("SUPER + ALT + left", fn.resize_active_window(-10, 0), e, "Resize window narrower")
bind("SUPER + ALT + right", fn.resize_active_window(10, 0), e, "Resize window wider")
bind("SUPER + ALT + up", fn.resize_active_window(0, -10), e, "Resize window shorter")
bind("SUPER + ALT + down", fn.resize_active_window(0, 10), e, "Resize window taller")
bind("SUPER + mouse:272", dsp.window.drag(), m, "Drag window")
bind(vars.kbMoveWindow, dsp.window.drag(), m, "Drag window")
bind("SUPER + mouse:273", dsp.window.resize(), m, "Drag resize window")
bind(vars.kbResizeWindow, dsp.window.resize(), m, "Drag resize window")
bind("CTRL + SUPER + Backslash", dsp.window.center(), nil, "Center window")
bind("CTRL + SUPER + ALT + Backslash", function()
    hl.dispatch(dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(dsp.window.center())
end, nil, "Resize window to 55%x70% and center")
bind(vars.kbWindowPip, exec("caelestia resizer pip"), nil, "Picture-in-picture window")
bind(vars.kbPinWindow, dsp.window.pin(), nil, "Pin window on all workspaces")
bind(vars.kbWindowFullscreen, dsp.window.fullscreen({ mode = "fullscreen" }), nil, "Toggle fullscreen")
bind(vars.kbWindowBorderedFullscreen, dsp.window.fullscreen({ mode = "maximized" }), nil, "Toggle fullscreen with borders")
bind(vars.kbToggleWindowFloating, dsp.window.float(), nil, "Toggle floating window")
bind(vars.kbCloseWindow, exec("~/.config/hypr/scripts/smart-close.sh"), nil, "Close window")

-- Special workspace toggles
bind(vars.kbSystemMonitor, dsp.workspace.toggle_special("sysmon"), nil, "Toggle system monitor overlay")
bind(vars.kbMusic, exec("~/.config/hypr/scripts/toggle-special-app.sh music 'spotify' flatpak run --env=__NV_PRIME_RENDER_OFFLOAD=1 --env=__GLX_VENDOR_LIBRARY_NAME=nvidia --env=__EGL_VENDOR_LIBRARY_FILENAMES=/usr/lib/x86_64-linux-gnu/GL/glvnd/egl_vendor.d/10_nvidia.json com.spotify.Client --remote-debugging-port=9222 --ozone-platform=x11 --ignore-gpu-blocklist --enable-gpu-rasterization"),
    nil, "Toggle music overlay")
bind(vars.kbWhatsapp, exec("~/.config/hypr/scripts/toggle-special-app.sh whatsapp 'whatsdesk|whatsapp' whatsdesk --ozone-platform-hint=wayland --enable-gpu-rasterization --enable-zero-copy --enable-features=UseOzonePlatform,WaylandWindowDecorations,CanvasOopRasterization"),
    nil, "Toggle WhatsApp overlay")
bind(vars.kbDiscord, exec([[~/.config/hypr/scripts/toggle-special-app.sh communication 'discord|equibop|vesktop|serein|cz\.viceverse\.serein' flatpak run cz.viceverse.serein]]),
    nil, "Toggle Discord overlay")

-- Apps
bind(vars.kbTerminal, exec("app2unit -- " .. vars.terminal), nil, "Open terminal")
bind(vars.kbBrowser, exec("app2unit -- " .. vars.browser), nil, "Open browser")
bind(vars.kbEditor, exec(vars.editor), nil, "Open AI agent picker")
bind(vars.kbFileExplorer, exec("app2unit -- " .. vars.fileExplorer), nil, "Open file manager")
bind("CTRL + ALT + Escape", exec("app2unit -- qps"), nil, "Open process manager")
bind("CTRL + ALT + V", exec("app2unit -- " .. vars.audioSettings), nil, "Open volume mixer")

-- Utilities
bind("CTRL + SUPER + F", exec("~/.local/bin/omen-fan-gui"), nil, "Open Omen fan control")
bind("SUPER + ALT + C", exec("~/.config/hypr/scripts/toggle-camera.sh"), nil, "Toggle camera driver")
bind("Print", exec("caelestia screenshot"), l, "Screenshot full screen to clipboard")
bind("SUPER + SHIFT + S", global("screenshotFreeze"), nil, "Screenshot region (freeze)")
bind("SUPER + SHIFT + ALT + S", global("screenshot"), nil, "Screenshot region")
bind("SUPER + ALT + R", exec("caelestia record -s"), nil, "Screen recording with sound")
bind("CTRL + ALT + R", exec("caelestia record"), nil, "Screen recording")
bind("SUPER + SHIFT + ALT + R", exec("caelestia record -r"), nil, "Screen recording region")
bind("SUPER + SHIFT + C", exec("hyprpicker -a"), nil, "Color picker")

-- Volume
bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), l, "Mute microphone toggle")
bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), l, "Mute speaker toggle")
bind("SUPER + SHIFT + M", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), l, "Mute speaker toggle")
bind("XF86AudioRaiseVolume", global("volumeUp"), le, "Volume up")
bind("XF86AudioLowerVolume", global("volumeDown"), le, "Volume down")

-- Sleep
bind("SUPER + SHIFT + L", exec("systemctl --no-block suspend"), l, "Suspend system")

-- Clipboard and emoji picker
bind("SUPER + V", exec("pkill fuzzel || caelestia clipboard"), nil, "Clipboard history menu")
bind("SUPER + ALT + V", exec("pkill fuzzel || caelestia clipboard -d"), nil, "Clipboard delete item menu")
bind("SUPER + Period", exec("pkill fuzzel || caelestia emoji -p"), nil, "Emoji picker")
bind("CTRL + SHIFT + ALT + V", exec('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'), l,
    "Autotype last copied text")

-- Testing
bind("SUPER + ALT + F12", exec(
    "notify-send -u low -i dialog-information-symbolic 'Test notification' " ..
    [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]] ..
    " -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
), l, "Test notification")
