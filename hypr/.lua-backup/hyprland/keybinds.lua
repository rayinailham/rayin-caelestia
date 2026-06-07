local vars = _G.vars

-- Helper function to make bindings cleaner and fix lowercase/comma issues
local function clean_key_combo(keys_str)
    if not keys_str then return "" end
    -- Replace commas with plus
    keys_str = keys_str:gsub(",", " + ")
    
    -- Preserve keysyms containing mod names from being capitalized
    keys_str = keys_str:gsub("[Ss][Uu][Pp][Ee][Rr]_[Ll]", "__SUPER_L__")
    keys_str = keys_str:gsub("[Ss][Uu][Pp][Ee][Rr]_[Rr]", "__SUPER_R__")
    keys_str = keys_str:gsub("[Cc][Tt][Rr][Ll]_[Ll]", "__CTRL_L__")
    keys_str = keys_str:gsub("[Cc][Tt][Rr][Ll]_[Rr]", "__CTRL_R__")
    keys_str = keys_str:gsub("[Aa][Ll][Tt]_[Ll]", "__ALT_L__")
    keys_str = keys_str:gsub("[Aa][Ll][Tt]_[Rr]", "__ALT_R__")
    keys_str = keys_str:gsub("[Ss][Hh][Ii][Ff][Tt]_[Ll]", "__SHIFT_L__")
    keys_str = keys_str:gsub("[Ss][Hh][Ii][Ff][Tt]_[Rr]", "__SHIFT_R__")

    -- Normalize modifiers to uppercase
    keys_str = keys_str:gsub("ctrl", "CTRL"):gsub("Ctrl", "CTRL")
                       :gsub("alt", "ALT"):gsub("Alt", "ALT")
                       :gsub("super", "SUPER"):gsub("Super", "SUPER")
                       :gsub("shift", "SHIFT"):gsub("Shift", "SHIFT")
                       
    -- Restore preserved keysyms with correct case
    keys_str = keys_str:gsub("__SUPER_L__", "Super_L")
    keys_str = keys_str:gsub("__SUPER_R__", "Super_R")
    keys_str = keys_str:gsub("__CTRL_L__", "Control_L")
    keys_str = keys_str:gsub("__CTRL_R__", "Control_R")
    keys_str = keys_str:gsub("__ALT_L__", "Alt_L")
    keys_str = keys_str:gsub("__ALT_R__", "Alt_R")
    keys_str = keys_str:gsub("__SHIFT_L__", "Shift_L")
    keys_str = keys_str:gsub("__SHIFT_R__", "Shift_R")

    -- Normalize spacing around plusses
    keys_str = keys_str:gsub("%s*%+%s*", " + ")
    -- Clean up multiple spaces
    keys_str = keys_str:gsub("%s+", " ")
    keys_str = keys_str:gsub("^%s+", ""):gsub("%s+$", "")
    return keys_str
end

local function bind(keys, action, flags)
    if not keys or keys == "" then return end
    hl.bind(clean_key_combo(keys), action, flags)
end

local function bind_exec(keys, cmd, flags)
    if not keys or keys == "" then return end
    hl.bind(clean_key_combo(keys), hl.dsp.exec_cmd(cmd), flags)
end

local function dsp(cmd, args)
    if cmd == "killactive" then
        return hl.dsp.window.close()
    elseif cmd == "togglefloating" then
        return hl.dsp.window.float()
    elseif cmd == "pin" then
        return hl.dsp.window.pin()
    elseif cmd == "fullscreen" then
        return hl.dsp.window.fullscreen({ state = tonumber(args) or 0 })
    elseif cmd == "centerwindow" then
        return hl.dsp.window.center({ preserve = tonumber(args) == 1 })
    elseif cmd == "movewindow" then
        if not args or args == "" then
            return hl.dsp.window.drag()
        elseif args == "l" then
            return hl.dsp.window.move({ direction = "left" })
        elseif args == "r" then
            return hl.dsp.window.move({ direction = "right" })
        elseif args == "u" then
            return hl.dsp.window.move({ direction = "up" })
        elseif args == "d" then
            return hl.dsp.window.move({ direction = "down" })
        end
    elseif cmd == "movefocus" then
        if args == "l" then
            return hl.dsp.focus({ direction = "left" })
        elseif args == "r" then
            return hl.dsp.focus({ direction = "right" })
        elseif args == "u" then
            return hl.dsp.focus({ direction = "up" })
        elseif args == "d" then
            return hl.dsp.focus({ direction = "down" })
        end
    elseif cmd == "workspace" then
        local ws = args
        if ws == "-1" then ws = "e-1"
        elseif ws == "+1" then ws = "e+1"
        elseif ws == "-10" then ws = "e-10"
        elseif ws == "+10" then ws = "e+10"
        end
        return hl.dsp.focus({ workspace = ws })
    elseif cmd == "movetoworkspace" then
        local ws = args
        if ws == "-1" then ws = "e-1"
        elseif ws == "+1" then ws = "e+1"
        end
        return hl.dsp.window.move({ workspace = ws, follow = true })
    elseif cmd == "cyclenext" then
        return hl.dsp.window.cycle_next({ prev = args == "prev" })
    elseif cmd == "changegroupactive" then
        if args == "f" then
            return hl.dsp.group.next()
        else
            return hl.dsp.group.prev()
        end
    elseif cmd == "togglegroup" then
        return hl.dsp.group.toggle()
    elseif cmd == "moveoutofgroup" then
        return hl.dsp.group.move_window()
    elseif cmd == "lockactivegroup" then
        return hl.dsp.group.lock_active({ action = args or "toggle" })
    elseif cmd == "resizewindow" then
        return hl.dsp.window.resize()
    elseif cmd == "resizeactive" then
        local is_exact = args:match("exact") ~= nil
        local clean_args = args:gsub("exact", "")
        local parts = {}
        for val in clean_args:gmatch("%S+") do
            table.insert(parts, val)
        end
        local x_str = parts[1] or "0"
        local y_str = parts[2] or "0"
        local x_pct = x_str:match("(.+)%%")
        local y_pct = y_str:match("(.+)%%")
        local x = tonumber(x_pct or x_str) or 0
        local y = tonumber(y_pct or y_str) or 0
        
        if is_exact then
            if x_pct then x = math.floor(1920 * x / 100) end
            if y_pct then y = math.floor(1080 * y / 100) end
            return hl.dsp.window.resize({ x = x, y = y, relative = false })
        else
            if x_pct then x = math.floor(1920 * x / 100) end
            if y_pct then y = math.floor(1080 * y / 100) end
            return hl.dsp.window.resize({ x = x, y = y, relative = true })
        end
    end
    return nil
end

-- All bindings registered in the global submap
hl.define_submap("global", function()
    -- Shell keybinds - Launcher (Bound to press to avoid lag, catchall handles interrupt)
    bind("SUPER + Super_L", hl.dsp.global("caelestia:launcher"), { ignore_mods = true })
    
    local mouse_keys = { "mouse:272", "mouse:273", "mouse:274", "mouse:275", "mouse:276", "mouse:277", "mouse_up", "mouse_down" }
    for _, key in ipairs(mouse_keys) do
        bind("SUPER + " .. key, hl.dsp.global("caelestia:launcherInterrupt"), { ignore_mods = true, non_consuming = true })
    end
    
    bind("catchall", hl.dsp.global("caelestia:launcherInterrupt"), { ignore_mods = true, non_consuming = true })

    -- Misc Shell Keybinds
    bind(vars.kbSession, hl.dsp.global("caelestia:session"))
    bind(vars.kbShowSidebar, hl.dsp.global("caelestia:sidebar"))
    bind(vars.kbClearNotifs, hl.dsp.global("caelestia:clearNotifs"), { locked = true })
    bind(vars.kbShowPanels, hl.dsp.global("caelestia:dashboard"))
    bind(vars.kbLock, hl.dsp.global("caelestia:lock"))

    -- Restore lock
    bind_exec(vars.kbRestoreLock, "caelestia shell -d", { locked = true })
    bind(vars.kbRestoreLock, hl.dsp.global("caelestia:lock"), { locked = true })

    -- Brightness
    bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
    bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

    -- Media
    bind("Ctrl + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    bind("Ctrl + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    bind("Ctrl + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
    bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

    -- Kill/restart
    bind_exec("Ctrl + SUPER + SHIFT + R", "caelestia shell -k", { release = true })
    bind_exec("Ctrl + SUPER + ALT + R", "caelestia shell -k; sleep .1; caelestia shell -d", { release = true })

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
    bind_exec(vars.kbDiscord, "caelestia toggle communication")

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
    bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"))
    bind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot"))
    bind_exec("SUPER + ALT + R", "caelestia record -s")
    bind_exec("Ctrl + ALT + R", "caelestia record")
    bind_exec("SUPER + SHIFT + ALT + R", "caelestia record -r")
    bind_exec("SUPER + SHIFT + C", "hyprpicker -a")

    -- Volume
    bind_exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
    bind_exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
    bind_exec("SUPER + SHIFT + M", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
    bind_exec("XF86AudioRaiseVolume", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+", { locked = true, repeating = true })
    bind_exec("XF86AudioLowerVolume", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-", { locked = true, repeating = true })

    -- Sleep
    bind_exec("SUPER + SHIFT + L", "systemctl --no-block suspend-then-hibernate", { locked = true })

    -- Clipboard and emoji picker
    bind_exec("SUPER + V", "pkill fuzzel || caelestia clipboard")
    bind_exec("SUPER + ALT + V", "pkill fuzzel || caelestia clipboard -d")
    bind_exec("SUPER + Period", "pkill fuzzel || caelestia emoji -p")
    bind_exec("Ctrl + SHIFT + ALT + V", 'sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"', { locked = true })

    -- Testing
    bind_exec("SUPER + ALT + f12", 'notify-send -u low -i dialog-information-symbolic \'Test notification\' "Here\'s a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!" -a \'Shell\' -A "Test1=I got it!" -A "Test2=Another action"', { locked = true })
end)

-- Enter global submap on config reload (deferred to prevent early startup crash)
hl.timer(function()
    hl.dispatch(hl.dsp.submap("global"))
end, { timeout = 50, type = "oneshot" })
