local vars = _G.vars

local function to_bool(v)
    if v == "true" or v == true then return true end
    if v == "false" or v == false then return false end
    return v
end

hl.config({
    decoration = {
        rounding = tonumber(vars.windowRounding),
        blur = {
            enabled = to_bool(vars.blurEnabled),
            xray = to_bool(vars.blurXray),
            special = to_bool(vars.blurSpecialWs),
            ignore_opacity = true,
            new_optimizations = true,
            popups = to_bool(vars.blurPopups),
            input_methods = to_bool(vars.blurInputMethods),
            size = tonumber(vars.blurSize),
            passes = tonumber(vars.blurPasses),
        },
        shadow = {
            enabled = to_bool(vars.shadowEnabled),
            range = tonumber(vars.shadowRange),
            render_power = tonumber(vars.shadowRenderPower),
            color = vars.shadowColour,
        }
    }
})
