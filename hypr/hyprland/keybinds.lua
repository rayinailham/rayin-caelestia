local vars = _G.vars

-- Helper function to make bindings cleaner and fix lowercase/comma issues
local function clean_key_combo(keys_str)
    if not keys_str then return "" end
    -- Replace commas with plus
    keys_str = keys_str:gsub(",", " + ")
    -- Normalize modifiers to uppercase
    keys_str = keys_str:gsub("ctrl", "CTRL"):gsub("Ctrl", "CTRL")
                       :gsub("alt", "ALT"):gsub("Alt", "ALT")
                       :gsub("super", "SUPER"):gsub("Super", "SUPER")
                       :gsub("shift", "SHIFT"):gsub("Shift", "SHIFT")
    -- Normalize spacing around plusses
    keys_str = keys_str:gsub("%s*%+%s*", " + ")
    -- Clean up multiple spaces
    keys_str = keys_str:gsub("%s+", " ")
    keys_str = keys_str:gsub("^%s+", ""):gsub("%s+$", "")
    return keys_str
end

local function bind(keys, action, flags)
    hl.bind(clean_key_combo(keys), action, flags)
end

local function bind_exec(keys, cmd, flags)
    hl.bind(clean_key_combo(keys), hl.dsp.exec_cmd(cmd), flags)
end

local function dsp(cmd, args)
    return function()
        hl.dispatch(cmd, args)
    end
end

-- Enter global submap on config reload
os.execute("hyprctl dispatch submap global")

-- All bindings registered in the global submap
hl.submap("global", function()
    -- Shell keybinds - Launcher
    bind("SUPER + SUPER_L", function() hl.dispatch("global", "caelestia:launcher") end, { ignore_mods = true })
    
    local mouse_keys = { "mouse:272", "mouse:273", "mouse:274", "mouse:275", "mouse:276", "mouse:277", "mouse_up", "mouse_down" }
    for _, key in ipairs(mouse_keys) do
        bind("SUPER + " .. key, function() hl.dispatch("global", "caelestia:launcherInterrupt") end, { ignore_mods = true, non_consuming = true })
    end
    
    bind("SUPER + catchall", function() hl.dispatch("global", "caelestia:launcherInterrupt") end, { ignore_mods = true, non_consuming = true })

    -- Misc Shell Keybinds
    bind(vars.kbSession, function() hl.dispatch("global", "caelestia:session") end)
    bind(vars.kbShowSidebar, function() hl.dispatch("global", "caelestia:sidebar") end)
    bind(vars.kbClearNotifs, function() hl.dispatch("global", "caelestia:clearNotifs") end, { locked = true })
    bind(vars.kbShowPanels, function() hl.dispatch("global", "caelestia:dashboard") end)
    bind(vars.kbLock, function() hl.dispatch("global", "caelestia:lock") end)

    -- Restore lock
    bind_exec(vars.kbRestoreLock, "caelestia shell -d", { locked = true })
    bind(vars.kbRestoreLock, function() hl.dispatch("global", "caelestia:lock") end, { locked = true })

    -- Brightness
    bind("XF86MonBrightnessUp", function() hl.dispatch("global", "caelestia:brightnessUp") end, { locked = true })
    bind("XF86MonBrightnessDown", function() hl.dispatch("global", "caelestia:brightnessDown") end, { locked = true })

    -- Media
    bind("Ctrl + SUPER + Space", function() hl.dispatch("global", "caelestia:mediaToggle") end, { locked = true })
    bind("XF86AudioPlay", function() hl.dispatch("global", "caelestia:mediaToggle") end, { locked = true })
    bind("XF86AudioPause", function() hl.dispatch("global", "caelestia:mediaToggle") end, { locked = true })
    bind("Ctrl + SUPER + Equal", function() hl.dispatch("global", "caelestia:mediaNext") end, { locked = true })
    bind("XF86AudioNext", function() hl.dispatch("global", "caelestia:mediaNext") end, { locked = true })
    bind("Ctrl + SUPER + Minus", function() hl.dispatch("global", "caelestia:mediaPrev") end, { locked = true })
    bind("XF86AudioPrev", function() hl.dispatch("global", "caelestia:mediaPrev") end, { locked = true })
    bind("XF86AudioStop", function() hl.dispatch("global", "caelestia:mediaStop") end, { locked = true })

    -- Kill/restart
    bind_exec("Ctrl + SUPER + SHIFT + R", "qs -c caelestia kill", { release = true })
    bind_exec("Ctrl + SUPER + ALT + R", "qs -c caelestia kill; sleep .1; caelestia shell -d", { release = true })

    -- Workspaces navigation and management
    local wsaction = "~/.config/hypr/scripts/wsaction.fish"
    for i = 1, 10 do
        local key = tostring(i % 10)
        bind(vars.kbGoToWs .. " + " .. key, hl.dsp.exec_cmd(wsaction .. " workspace " .. i))
        bind(vars.kbGoToWsGroup .. " + " .. key, hl.dsp.exec_cmd(wsaction .. " -g workspace " .. i))
        bind(vars.kbMoveWinToWs .. " + " .. key, hl.dsp.exec_cmd(wsaction .. " movetoworkspace " .. i))
        bind(vars.kbMoveWinToWsGroup .. " + " .. key, hl.dsp.exec_cmd(wsaction .. " -g movetoworkspace " .. i))
    end

    -- Go to workspace -1/+1
    bind("SUPER + mouse_down", dsp("workspace", "-1"))
    bind("SUPER + mouse_up", dsp("workspace", "+1"))
    bind(vars.kbPrevWs, dsp("workspace", "-1"), { repeating = true })
    bind(vars.kbNextWs, dsp("workspace", "+1"), { repeating = true })
    bind("SUPER + Page_Up", dsp("workspace", "-1"), { repeating = true })
    bind("SUPER + Page_Down", dsp("workspace", "+1"), { repeating = true })

    -- Go to workspace group -1/+1
    bind("Ctrl + SUPER + mouse_down", dsp("workspace", "-10"))
    bind("Ctrl + SUPER + mouse_up", dsp("workspace", "+10"))

    -- Toggle special workspace
    bind_exec(vars.kbToggleSpecialWs, "caelestia toggle specialws")

    -- Move window to workspace -1/+1
    bind("SUPER + ALT + Page_Up", dsp("movetoworkspace", "-1"), { repeating = true })
    bind("SUPER + ALT + Page_Down", dsp("movetoworkspace", "+1"), { repeating = true })
    bind("SUPER + ALT + mouse_down", dsp("movetoworkspace", "-1"))
    bind("SUPER + ALT + mouse_up", dsp("movetoworkspace", "+1"))
    bind("Ctrl + SUPER + SHIFT + right", dsp("movetoworkspace", "+1"), { repeating = true })
    bind("Ctrl + SUPER + SHIFT + left", dsp("movetoworkspace", "-1"), { repeating = true })

    -- Move window to/from special workspace
    bind("Ctrl + SUPER + SHIFT + up", dsp("movetoworkspace", "special:special"))
    bind("Ctrl + SUPER + SHIFT + down", dsp("movetoworkspace", "e+0"))
    bind("SUPER + ALT + S", dsp("movetoworkspace", "special:special"))

    -- Window groups
    bind(vars.kbWindowGroupCycleNext, dsp("cyclenext"), { repeating = true })
    bind(vars.kbWindowGroupCyclePrev, dsp("cyclenext", "prev"), { repeating = true })
    bind("Ctrl + ALT + Tab", dsp("changegroupactive", "f"), { repeating = true })
    bind("Ctrl + SHIFT + ALT + Tab", dsp("changegroupactive", "b"), { repeating = true })
    bind(vars.kbToggleGroup, dsp("togglegroup"))
    bind(vars.kbUngroup, dsp("moveoutofgroup"))
    bind("SUPER + SHIFT + Comma", dsp("lockactivegroup", "toggle"))

    -- Window actions
    bind("SUPER + left", dsp("movefocus", "l"))
    bind("SUPER + right", dsp("movefocus", "r"))
    bind("SUPER + up", dsp("movefocus", "u"))
    bind("SUPER + down", dsp("movefocus", "d"))
    bind("SUPER + SHIFT + left", dsp("movewindow", "l"))
    bind("SUPER + SHIFT + right", dsp("movewindow", "r"))
    bind("SUPER + SHIFT + up", dsp("movewindow", "u"))
    bind("SUPER + SHIFT + down", dsp("movewindow", "d"))

    bind("SUPER + Minus", dsp("resizeactive", "-10% 0"), { repeating = true })
    bind("SUPER + Equal", dsp("resizeactive", "10% 0"), { repeating = true })
    bind("SUPER + SHIFT + Minus", dsp("resizeactive", "0 -10%"), { repeating = true })
    bind("SUPER + SHIFT + Equal", dsp("resizeactive", "0 10%"), { repeating = true })
    bind("SUPER + ALT + left", dsp("resizeactive", "-10% 0"), { repeating = true })
    bind("SUPER + ALT + right", dsp("resizeactive", "10% 0"), { repeating = true })
    bind("SUPER + ALT + up", dsp("resizeactive", "0 -10%"), { repeating = true })
    bind("SUPER + ALT + down", dsp("resizeactive", "0 10%"), { repeating = true })

    bind("SUPER + mouse:272", dsp("movewindow"), { mouse = true })
    bind(vars.kbMoveWindow, dsp("movewindow"), { mouse = true })
    bind("SUPER + mouse:273", dsp("resizewindow"), { mouse = true })
    bind(vars.kbResizeWindow, dsp("resizewindow"), { mouse = true })

    bind("Ctrl + SUPER + Backslash", dsp("centerwindow", "1"))
    bind("Ctrl + SUPER + ALT + Backslash", dsp("resizeactive", "exact 55% 70%"))
    bind("Ctrl + SUPER + ALT + Backslash", dsp("centerwindow", "1"))

    bind_exec(vars.kbWindowPip, "caelestia resizer pip")
    bind(vars.kbPinWindow, dsp("pin"))
    bind(vars.kbWindowFullscreen, dsp("fullscreen", "0"))
    bind(vars.kbWindowBorderedFullscreen, dsp("fullscreen", "1"))
    bind(vars.kbToggleWindowFloating, dsp("togglefloating"))
    bind(vars.kbCloseWindow, dsp("killactive"))

    -- Special workspace toggles
    bind_exec(vars.kbSystemMonitor, "caelestia toggle sysmon")
    bind_exec(vars.kbMusic, "caelestia toggle music")
    bind_exec(vars.kbWhatsapp, "caelestia toggle whatsapp")
    bind_exec(vars.kbTeams, "caelestia toggle teams")

    -- Apps
    bind_exec(vars.kbTerminal, "app2unit -- " .. vars.terminal)
    bind_exec(vars.kbBrowser, "caelestia toggle browser")
    bind_exec(vars.kbEditor, "app2unit -- " .. vars.editor)
    bind_exec(vars.kbGithub, "app2unit -- github-desktop")
    bind_exec(vars.kbFileExplorer, "app2unit -- " .. vars.fileExplorer)
    bind_exec("Ctrl + ALT + Escape", "app2unit -- qps")
    bind_exec("Ctrl + ALT + V", "app2unit -- pavucontrol")

    -- Utilities
    bind_exec("Print", "caelestia screenshot", { locked = true })
    bind("SUPER + SHIFT + S", function() hl.dispatch("global", "caelestia:screenshotFreeze") end)
    bind("SUPER + SHIFT + ALT + S", function() hl.dispatch("global", "caelestia:screenshot") end)
    bind_exec("SUPER + ALT + R", "caelestia record -s")
    bind_exec("Ctrl + ALT + R", "caelestia record")
    bind_exec("SUPER + SHIFT + ALT + R", "caelestia record -r")
    bind_exec("SUPER + SHIFT + C", "hyprpicker -a")
    bind_exec("SUPER + ALT + W", "fish -c work-wallpaper")
    bind_exec("SUPER + ALT + G", "fish -c goon-wallpaper")

    -- Volume
    bind_exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
    bind_exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
    bind_exec("SUPER + SHIFT + M", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
    bind_exec("XF86AudioRaiseVolume", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+", { locked = true, repeating = true })
    bind_exec("XF86AudioLowerVolume", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-", { locked = true, repeating = true })

    -- Sleep
    bind_exec("SUPER + SHIFT + L", "systemctl suspend-then-hibernate", { locked = true })

    -- Clipboard and emoji picker
    bind_exec("SUPER + V", "pkill fuzzel || caelestia clipboard")
    bind_exec("SUPER + ALT + V", "pkill fuzzel || caelestia clipboard -d")
    bind_exec("SUPER + Period", "pkill fuzzel || caelestia emoji -p")
    bind_exec("Ctrl + SHIFT + ALT + V", 'sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"', { locked = true })

    -- Testing
    bind_exec("SUPER + ALT + f12", 'notify-send -u low -i dialog-information-symbolic \'Test notification\' "Here\'s a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!" -a \'Shell\' -A "Test1=I got it!" -A "Test2=Another action"', { locked = true })
end)
