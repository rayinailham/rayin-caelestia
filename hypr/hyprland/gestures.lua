local vars = require("variables")

local function exec(cmd)
    return function() hl.exec_cmd(cmd) end
end

hl.config({
    gestures = {
        workspace_swipe_distance                 = 700,
        workspace_swipe_cancel_ratio             = 0.15,
        workspace_swipe_min_speed_to_force       = 5,
        workspace_swipe_direction_lock           = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new               = true,
    },
})

hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = vars.gestureFingers, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = vars.gestureFingers, direction = "up", action = exec("~/.config/hypr/scripts/close-special-ws.sh") })
hl.gesture({ fingers = vars.gestureFingers, direction = "down", action = exec("~/.config/hypr/scripts/swipe-special.sh") })
hl.gesture({ fingers = vars.gestureFingersMore, direction = "down", action = exec(vars.sleepGestureCmd) })
