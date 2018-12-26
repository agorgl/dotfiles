--
-- line.lua
--
require 'cairo'
require 'util'

local requirements = {
    line      = { 'from', 'to' },
    bar_graph = { 'from', 'to', 'value' },
}

local defaults = {
    line = {
        color                    = 0x00FF6E,
        alpha                    = 0.2,
        thickness                = 5,
        graduated                = false,
        number_graduation        = 0,
        space_between_graduation = 1,
        draw_function            = draw_line,
    },
    bar_graph = {
        value                         = 40.,
        max_value                     = 100.,
        critical_threshold            = 90.,

        background_color              = 0x00FF6E,
        background_alpha              = 0.2,
        background_thickness          = 5,

        bar_color                     = 0x00FF6E,
        bar_alpha                     = 1.0,
        bar_thickness                 = 5,

        background_color_critical     = 0xFA002E,
        background_alpha_critical     = 0.2,
        background_thickness_critical = 5,

        bar_color_critical            = 0xFA002E,
        bar_alpha_critical            = 1.0,
        bar_thickness_critical        = 5,

        change_color_on_critical      = true,
        change_alpha_on_critical      = false,
        change_thickness_on_critical  = false,

        graduated                     = false,
        number_graduation             = 0,
        space_between_graduation      = 1,
    },
}

--
-- Draw a line
--
function draw_line(display, element)
    -- Check required and fill defaults
    check_requirements(element, requirements.line)
    fill_defaults(element, defaults.line)

    -- Deltas for x and y (cairo expects a point and deltas for both axis)
    local x_side = element.to.x - element.from.x -- not abs! because they are deltas
    local y_side = element.to.y - element.from.y -- and the same here
    local from_x = element.from.x
    local from_y = element.from.y

    if not element.graduated then
        -- Draw line
        cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
        cairo_set_line_width(display, element.thickness);
        cairo_move_to(display, element.from.x, element.from.y);
        cairo_rel_line_to(display, x_side, y_side);
    else
        -- Draw graduated line
        cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
        cairo_set_line_width(display, element.thickness);
        local space_graduation_x = (x_side-x_side / element.space_between_graduation + 1) / element.number_graduation
        local space_graduation_y = (y_side-y_side / element.space_between_graduation + 1) / element.number_graduation
        local space_x = x_side / element.number_graduation - space_graduation_x
        local space_y = y_side / element.number_graduation - space_graduation_y

        for i = 1, element.number_graduation do
            cairo_move_to(display, from_x, from_y)
            from_x = from_x + space_x + space_graduation_x
            from_y = from_y + space_y + space_graduation_y
            cairo_rel_line_to(display, space_x, space_y)
        end
    end
    cairo_stroke(display)
end

--
-- Draw a bar graph
--   Used a little bit of trigonometry to be able to draw bars in any direction! :)
--
function draw_bar_graph(display, element)
    -- Check required and fill defaults
    check_requirements(element, requirements.bar_graph)
    fill_defaults(element, defaults.bar_graph)

    -- Get current value
    value = element.value
    if value > element.max_value then
        value = element.max_value
    end

    -- Dimensions of the full graph
    local x_side = element.to.x - element.from.x
    local y_side = element.to.y - element.from.y
    local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
    local angle = math.atan2(y_side, x_side)

    -- Dimensions of the value bar
    local bar_hypotenuse = value * (hypotenuse / element.max_value)
    local bar_x_side = bar_hypotenuse * math.cos(angle)
    local bar_y_side = bar_hypotenuse * math.sin(angle)

    -- Is it in critical value?
    local color_critical_or_not_suffix = ''
    local alpha_critical_or_not_suffix = ''
    local thickness_critical_or_not_suffix = ''
    if value >= element.critical_threshold then
        if element.change_color_on_critical then
            color_critical_or_not_suffix = '_critical'
        end
        if element.change_alpha_on_critical then
            alpha_critical_or_not_suffix = '_critical'
        end
        if element.change_thickness_on_critical then
            thickness_critical_or_not_suffix = '_critical'
        end
    end

    -- Background line (full graph)
    background_line = {
        from                     = element.from,
        to                       = element.to,
        color                    = element['background_color'     .. color_critical_or_not_suffix],
        alpha                    = element['background_alpha'     .. alpha_critical_or_not_suffix],
        thickness                = element['background_thickness' .. thickness_critical_or_not_suffix],
        graduated                = element.graduated,
        number_graduation        = element.number_graduation,
        space_between_graduation = element.space_between_graduation,
    }
    bar_line = {
        from      = element.from,
        to        = { x = element.from.x + bar_x_side, y = element.from.y + bar_y_side },
        color     = element['bar_color' .. color_critical_or_not_suffix],
        alpha     = element['bar_alpha' .. alpha_critical_or_not_suffix],
        thickness = element['bar_thickness' .. thickness_critical_or_not_suffix],
    }
    -- Draw background lines
    draw_line(display, background_line)

    if element.graduated then
        -- Draw bar line if graduated
        cairo_set_source_rgba(display, hexa_to_rgb(bar_line.color, bar_line.alpha))
        cairo_set_line_width(display, bar_line.thickness);

        local from_x = bar_line.from.x
        local from_y = bar_line.from.y
        local space_graduation_x = (x_side - x_side / element.space_between_graduation + 1) / element.number_graduation
        local space_graduation_y = (y_side - y_side / element.space_between_graduation + 1) / element.number_graduation
        local space_x = x_side / element.number_graduation - space_graduation_x
        local space_y = y_side / element.number_graduation - space_graduation_y

        for i = 1, bar_x_side / (space_x + space_graduation_x) do
            cairo_move_to(display, from_x, from_y)
            from_x = from_x + space_x + space_graduation_x
            from_y = from_y + space_y + space_graduation_y
            cairo_rel_line_to(display, space_x, space_y)
        end

        cairo_stroke(display)
    else
        -- Draw bar line if not graduated
        draw_line(display, bar_line);
    end
end
