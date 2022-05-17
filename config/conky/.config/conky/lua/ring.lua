require 'cairo'
require 'util'

local requirements = {
    ring       = { 'center', 'radius' },
    ring_graph = { 'center', 'radius', 'value' },
}

local defaults = {
    ring = {
        color                    = 0x00FF6E,
        alpha                    = 0.2,
        thickness                = 5,

        start_angle              = 0,
        end_angle                = 360,

        graduated                = false,
        number_graduation        = 0,
        angle_between_graduation = 1,
    },
    ring_graph = {
        value                         = 40.,
        max_value                     = 100.,
        critical_threshold            = 90.,

        bar_color                     = 0x00FF6E,
        bar_alpha                     = 1.0,
        bar_thickness                 = 5,
        bar_color_critical            = 0xFA002E,
        bar_alpha_critical            = 1.0,
        bar_thickness_critical        = 5,

        background_color              = 0x00FF6E,
        background_alpha              = 0.2,
        background_thickness          = 5,
        background_color_critical     = 0xFA002E,
        background_alpha_critical     = 0.2,
        background_thickness_critical = 5,

        outline_color                 = 0x00FF6E,
        outline_alpha                 = 0.5,
        outline_thickness             = 0,
        outline_color_critical        = 0xFA002E,
        outline_alpha_critical        = 0.5,
        outline_thickness_critical    = 1,

        change_color_on_critical      = true,
        change_alpha_on_critical      = false,
        change_thickness_on_critical  = false,

        start_angle                   = 0,
        end_angle                     = 360,

        graduated                     = false,
        number_graduation             = 0,
        angle_between_graduation      = 1,
    },
}

--
-- Draw a ring
--
function draw_ring(display, element)
    -- Check required and fill defaults
    check_requirements(element, requirements.ring)
    fill_defaults(element, defaults.ring)

    -- The user types degrees, but we need radians
    local start_angle, end_angle = math.rad(element.start_angle), math.rad(element.end_angle)

    -- Direction of the ring changes the function we must call
    local arc_drawer = cairo_arc
    local orientation = 1
    if start_angle > end_angle then
        arc_drawer = cairo_arc_negative
        orientation = -1
    end
    cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
    cairo_set_line_width(display, element.thickness);

    -- Draw the ring
    if not element.graduated then
        -- Draw the ring if not graduated
        arc_drawer(display,
                   element.center.x,
                   element.center.y,
                   element.radius,
                   start_angle,
                   end_angle)
        cairo_stroke(display);
    else
        -- Draw the ring if graduated
        local angle_between_graduation = math.rad(element.angle_between_graduation)
        local graduation_size = math.abs(end_angle - start_angle) / element.number_graduation - angle_between_graduation
        local current_start = start_angle

        for i = 1, element.number_graduation do
            arc_drawer(display,
                       element.center.x,
                       element.center.y,
                       element.radius,
                       current_start,
                       current_start + graduation_size * orientation)
                       current_start = current_start + (graduation_size + angle_between_graduation) * orientation
            cairo_stroke(display);
        end
    end
end

--
-- Draw a ring graph
--
function draw_ring_graph(display, element)
    -- Check required and fill defaults
    check_requirements(element, requirements.ring_graph)
    fill_defaults(element, defaults.ring_graph)

    -- Get current value
    local value = element.value
    if value > element.max_value then
        value = element.max_value
    end

    -- Dimensions of the full graph
    local degrees = element.end_angle - element.start_angle

    -- Dimensions of the value bar
    local bar_degrees = value * (degrees / element.max_value)

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

    -- Background ring (full graph)
    background_ring = {
        center      = element.center,
        radius      = element.radius,
        start_angle = element.start_angle,
        end_angle   = element.end_angle,
        graduated   = element.graduated,
        color       = element['background_color'     .. color_critical_or_not_suffix],
        alpha       = element['background_alpha'     .. alpha_critical_or_not_suffix],
        thickness   = element['background_thickness' .. thickness_critical_or_not_suffix],
        number_graduation        = element.number_graduation,
        angle_between_graduation = element.angle_between_graduation,
    }

    -- Bar ring
    bar_ring = {
        center      = element.center,
        radius      = element.radius,
        start_angle = element.start_angle,
        end_angle   = element.start_angle + bar_degrees,
        color       = element['bar_color'     .. color_critical_or_not_suffix],
        alpha       = element['bar_alpha'     .. alpha_critical_or_not_suffix],
        thickness   = element['bar_thickness' .. thickness_critical_or_not_suffix],
    }

    -- Outline ring (full graph)
    outline_ring = {
        center      = element.center,
        radius      = element.radius + bar_ring.thickness / 2,
        start_angle = element.start_angle,
        end_angle   = element.end_angle,
        graduated   = element.graduated,
        color       = element['outline_color'     .. color_critical_or_not_suffix],
        alpha       = element['outline_alpha'     .. alpha_critical_or_not_suffix],
        thickness   = element['outline_thickness' .. thickness_critical_or_not_suffix],
        number_graduation        = element.number_graduation,
        angle_between_graduation = element.angle_between_graduation,
    }

    -- Draw background ring
    draw_ring(display, background_ring)
    if not element.graduated then
        -- Draw bar ring if not graduated
        draw_ring(display, bar_ring)
    else
        -- Draw bar ring if graduated
        local start_angle, end_angle = math.rad(element.start_angle), math.rad(element.end_angle)
        local arc_drawer = cairo_arc
        local orientation = 1
        if start_angle > end_angle then
            arc_drawer = cairo_arc_negative
            orientation = -1
        end
        cairo_set_source_rgba(display, hexa_to_rgb(bar_ring.color, bar_ring.alpha))
        cairo_set_line_width(display, bar_ring.thickness);

        local angle_between_graduation = math.rad(element.angle_between_graduation)
        local graduation_size = math.abs(end_angle - start_angle) / element.number_graduation - angle_between_graduation
        local current_start = start_angle
        bar_degrees = math.rad(bar_degrees)
        for i = 1, bar_degrees / (graduation_size + angle_between_graduation) * orientation do
            arc_drawer(display,
                       element.center.x,
                       element.center.y,
                       element.radius,
                       current_start,
                       current_start + graduation_size * orientation)
            current_start = current_start + (graduation_size + angle_between_graduation) * orientation
            cairo_stroke(display);
        end
    end
    -- Draw outline ring
    if outline_ring.thickness > 0 then
        draw_ring(display, outline_ring)
    end
end
