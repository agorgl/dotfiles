--
-- clock.lua
--

-- Extend package search to directory of current script
current_path = debug.getinfo(1).source:match("@?(.*/)")
package.path = current_path .. "?.lua;" .. package.path

require 'conf'
require 'util'
require 'cairo'
require 'cairo_xlib'

-- Constants
CLOCK_FONT      = "Open Sans"
CLOCK_R         = 125
CLOCK_X         = 160
CLOCK_Y         = 155
CPUGRAPH_LENGTH = 330

-- Arc values
arc_settings_table = {
    {
        name = 'time',
        arg = '%I.%M',
        max = 12,
        bg_alpha = 0.1,
        fg_alpha = 0.2,
        radius = 50,
        thickness = 5,
        start_angle = 0,
        end_angle = 360
    },
    {
        name = 'time',
        arg = '%M.%S',
        max = 60,
        bg_alpha = 0.1,
        fg_alpha = 0.4,
        radius = 56,
        thickness = 5,
        start_angle = 0,
        end_angle = 360
    },
    {
        name = 'time',
        arg = '%S',
        max = 60,
        bg_alpha = 0.1,
        fg_alpha = 0.6,
        radius = 62,
        thickness = 5,
        start_angle = 0,
        end_angle = 360
    },
    {
        name = 'cpu',
        arg = 'cpu0',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.5,
        radius = 78.5,
        thickness = 10,
        start_angle = 93,
        end_angle = 208
    },
    {
        name = 'memperc',
        arg = '',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.5,
        radius = 78.5,
        thickness = 10,
        start_angle = 212,
        end_angle = 329
    },
    {
        name = 'wireless_link_qual_perc',
        arg = 'wlp8s0',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.5,
        radius = 78.5,
        thickness = 10,
        start_angle = -27,
        end_angle = 85
    },
    {
        name = 'fs_used_perc',
        arg = '/',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.5,
        radius = 105,
        thickness = 3,
        start_angle = -120,
        end_angle = -13
    },
    {
        name = 'fs_used_perc',
        arg = '/home',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.5,
        radius = 105,
        thickness = 3,
        start_angle = -10,
        end_angle = 120
    },
    {
        name = 'cpu',
        arg = 'cpu0',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.6,
        radius = 120,
        thickness = 2,
        start_angle = 75,
        end_angle = 105
    },
    {
        name = 'cpu',
        arg = 'cpu0',
        max = 100,
        bg_alpha = 0.2,
        fg_alpha = 0.6,
        radius = 450,
        thickness = 2,
        start_angle = 86,
        end_angle = 94
    },
}

function draw_ring(cr, t, pt)
    local w, h = conky_window.width, conky_window.height

    local xc, yc, ring_r, ring_w, sa, ea = CLOCK_X, CLOCK_Y, pt['radius'], pt['thickness'], pt['start_angle'], pt['end_angle']
    local bgc, bga, fgc, fga = config_color("main"), pt['bg_alpha'], config_color("main"), pt['fg_alpha']

    local angle_0 = sa * (2 * math.pi / 360) - math.pi / 2
    local angle_f = ea * (2 * math.pi / 360) - math.pi / 2
    local t_arc = t * (angle_f - angle_0)

    -- Draw background arc
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a({bgc, bga}))
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)

    -- Draw foreground arc
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a({fgc, fga}))
    cairo_stroke(cr)
end

--
-- Draws main clock hands
--
function draw_clock_hands(cr, xc, yc)
    local clock_colour = {config_color("main"), 0.8}
    local secs, mins, hours, secs_arc, mins_arc, hours_arc
    local xh, yh, xm, ym, xs, ys

    secs = os.date("%S")
    mins = os.date("%M")
    hours = os.date("%I")

    secs_arc = (2 * math.pi / 60) * secs
    mins_arc = (2 * math.pi / 60) * mins + secs_arc / 60
    hours_arc = (2 * math.pi / 12) * hours + mins_arc / 12

    xh = xc + 0.7 * CLOCK_R * math.sin(hours_arc)
    yh = yc - 0.7 * CLOCK_R * math.cos(hours_arc)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xh, yh)

    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr, 5)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(clock_colour))
    cairo_stroke(cr)

    xm = xc + CLOCK_R * math.sin(mins_arc)
    ym = yc - CLOCK_R * math.cos(mins_arc)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xm, ym)

    cairo_set_line_width(cr, 3)
    cairo_stroke(cr)

    -- Show seconds
    xs = xc + CLOCK_R * math.sin(secs_arc)
    ys = yc - CLOCK_R * math.cos(secs_arc)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xs, ys)

    cairo_set_line_width(cr, 1)
    cairo_stroke(cr)
end

--
-- Calculates ring fill percentage
--
function calc_ring_pct(cr, pt)
    local str = ''
    local value = 0

    str = string.format('${%s %s}', pt['name'], pt['arg'])
    str = conky_parse(str)

    value = tonumber(str)
    if value == nil then
        value = 0
    end
    pct = value / pt['max']
    return pct
end

--
-- Setups font parameters for date and time texts
--
function setup_dtime_font(cr, font_sz)
    -- Set font properties
    cairo_select_font_face(cr, CLOCK_FONT, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, font_sz)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a({config_color('altn'), 0xFF}))
end

--
-- Draws current date as a full sentence bellow cpugraph
--
function draw_analytic_date(cr, x, y)
    -- Setup pivot point
    local px = x + 8
    local py = y + 22
    -- Setup datetime font
    setup_dtime_font(cr, 18)
    local text = conky_parse("${time %A %d %B %Y}")
    cairo_move_to(cr, px, py)
    cairo_show_text(cr, text)
    cairo_stroke(cr)
end

--
-- Draws bottom line of cpugraph
--
function draw_graph_line(cr, x_pivot, y_pivot)
    local x = x_pivot + 120
    local y = y_pivot + 1
    local length = CPUGRAPH_LENGTH
    cairo_move_to(cr, x, y)
    cairo_line_to(cr, x + length, y)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr, 1)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a({config_color("main"), 0xF0}))
    cairo_stroke(cr)
    return x, y
end

--
-- Draws time as text centered inside the clock
--
function draw_time(cr)
    -- Setup datetime font
    setup_dtime_font(cr, 25)
    -- Current time
    local hours = os.date("%H")
    local mins = os.date("%M")
    local time_text = hours .. ":" .. mins
    -- Calculate text positioning
    -- Members: x_bearing y_bearing width height x_advance y_advance
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, time_text, extents)
    local x = CLOCK_X - (extents.width) / 2
    local y = CLOCK_Y + (extents.height) / 2
    -- Draw text
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, time_text)
    cairo_stroke(cr)
end

function clock_text()
    -- Skip some ticks
    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)
    if update_num <= 5 then return "" end

    -- CPU Graph
    local height = 50
    local width = CPUGRAPH_LENGTH - 1
    local x = cpugraph_x
    local y = cpugraph_y - (height + conky_window.text_start_y + 10)
    local color0, color1 = 0xd5dcde, 0x808080
    local s = "${goto %d}${voffset %d}${cpugraph %u,%u %x %x}"
    local cpugtxt = s:format(x, y, height, width, color0, color1)
    return cpugtxt
end
conky_clock_text = clock_text

function clock_main(cr)
    -- Clock
    for i in pairs(arc_settings_table) do
        local pt = arc_settings_table[i]
        local pct = calc_ring_pct(cr, pt)
        draw_ring(cr, pct, pt)
    end
    draw_clock_hands(cr, CLOCK_X, CLOCK_Y)

    -- Time
    draw_time(cr)

    -- Date
    gx, gy = draw_graph_line(cr, CLOCK_X, CLOCK_Y)
    draw_analytic_date(cr, gx, gy)

    -- Store to use by clock_text()
    cpugraph_x, cpugraph_y = gx, gy
end

-- Alias for conky config to find it
conky_clock_main = function()
    main_common(clock_main)
end
