--
-- temps.lua
--

-- Extend package search to directory of current script
current_path = debug.getinfo(1).source:match("@?(.*/)")
package.path = current_path .. "?.lua;" .. package.path

require 'cairo'
require 'cairo_xlib'
require 'conf'
require 'text'
require 'line'
require 'ring'

local CELSIUS_SYMBOL = 'C°'
local HAS_NVIDIA = command_exec('lshw -C display 2>/dev/null | grep -i nvidia') == 0
local AMD_TEMP_CMD = "sensors | grep -P -A 4 '(radeon|amdgpu)' | awk '/(temp|edge)/{ print $2 }' | sed 's/[^0-9.]//g'"

function table.copy(t)
    local u = {}
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end

function temperature_widget(display, pos, sa, ea, label, value)
    local color_prim = config_color('main')
    local color_text = config_color('altn')

    -- Ring graph
    local r = {
        center = pos,
        radius = 36,
        value  = value,

        bar_color        = color_prim,
        background_color = color_prim,

        bar_thickness        = 10,
        background_thickness = 10,

        start_angle = sa,
        end_angle = ea,

        graduated = true,
        number_graduation = 30,
        angle_between_graduation = 3,
        change_color_on_critical = false,
    }
    draw_ring_graph(display, r)

    -- Value
    local val_pos = table.copy(pos)
    val_pos.x = val_pos.x - 4
    local t = {
        from = val_pos,
        text = ' ' .. tostring(math.ceil(value)) .. CELSIUS_SYMBOL,
        font_size = 20,
        color = color_text,
        halign = 'center',
        valign = 'center',
    }
    draw_text(display, t)

    -- Label
    local lbl_pos = table.copy(pos)
    lbl_pos.x = pos.x - r.radius - r.bar_thickness / 2 - 4
    lbl_pos.y = pos.y + r.radius - 4
    local l = {
        from = lbl_pos,
        text = label,
        font_size = 17,
        color = color_prim,
        halign = 'left',
        valign = 'bottom',
    }
    draw_text(display, l)
end

coremon = command([=[
    for m in /sys/class/hwmon/*; do [[ -f $m/temp1_input ]] && paste <(cat $m/name) <(echo $m/temp1_input); done \
  | awk '/(coretemp|k10temp)/{print $2}' | grep -Po '(?<=hwmon)\d+']=])

function temps_main(display)
    local cpu_temp = conky_value('hwmon ' .. coremon .. ' temp 1', true)
    local gpu_temp = 0
    if HAS_NVIDIA then
        gpu_temp = conky_value('nvidia temp', true)
    else
        gpu_temp = tonumber(command(AMD_TEMP_CMD))
    end

    temperature_widget(display, { x = 60,  y = 60 }, -160, 70, 'CPU', cpu_temp)
    temperature_widget(display, { x = 200, y = 60 }, -160, 70, 'GPU', gpu_temp)
end

-- Alias for conky config to find it
conky_temps_main = function()
    main_common(temps_main)
end
