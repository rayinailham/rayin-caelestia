local vars = _G.vars

hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    }
})

hl.gesture({
    fingers = tonumber(vars.workspaceSwipeFingers),
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = tonumber(vars.gestureFingers),
    direction = "up",
    action = "special",
})

hl.gesture({
    fingers = tonumber(vars.gestureFingers),
    direction = "down",
    action = function()
        hl.exec_cmd("caelestia toggle specialws")
    end,
})

hl.gesture({
    fingers = tonumber(vars.gestureFingersMore),
    direction = "down",
    action = function()
        hl.exec_cmd("systemctl suspend-then-hibernate")
    end,
})
