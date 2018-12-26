require 'cairo'
require 'util'

local requirements = {
    text = { 'from', 'text' },
}

local defaults = {
    text = {
        color = 0x00FF6E,
        rotation_angle = 0,
        font = "Liberation Sans",
        font_size = 12,
        bold = false,
        italic = false,
        alpha = 1.0,
        halign = 'left', -- left, center, right
        valign = 'bottom', -- top, center, bottom
    },
}

local function set_font_options(display)
    local fnt_opts
    fnt_opts = cairo_font_options_create()
    cairo_font_options_set_antialias(fnt_opts, CAIRO_ANTIALIAS_BEST)
    cairo_font_options_set_hint_style(fnt_opts, CAIRO_HINT_STYLE_FULL)
    cairo_font_options_set_hint_metrics(fnt_opts, CAIRO_HINT_METRICS_ON)
    cairo_set_font_options(display, fnt_opts)
    cairo_font_options_destroy(fnt_opts)
end

function draw_text(display, element)
    check_requirements(element, requirements.text)
    fill_defaults(element, defaults.text)

    cairo_save(display)
    cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
    cairo_set_font_size(display, element.font_size)

    font_slant  = element.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL
    font_weight = element.bold   and CAIRO_FONT_WEIGHT_BOLD  or CAIRO_FONT_WEIGHT_NORMAL
    cairo_select_font_face(display, element.font, font_slant, font_weight)

    -- Calculate text decoration positioning
    -- Members: x_bearing, y_bearing, width, height, x_advance, y_advance
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(display, element.text, extents)
    -- Members: ascent, descent, height, max_x_advance, max_y_advance
    local metrics = cairo_font_extents_t:create()
    cairo_font_extents(display, metrics)

    halign_actions = {
        left =
            function()
            end,
        center =
            function()
                element.from.x = element.from.x - extents.width / 2
            end,
        right =
            function()
                element.from.x = element.from.x - extents.width
            end,
    }
    halign_actions[element.halign]()

    valign_actions = {
        top =
            function()
                element.from.y = element.from.y + extents.height
            end,
        center =
            function()
                element.from.y = element.from.y + (metrics.ascent - metrics.descent) / 2
            end,
        bottom =
            function()
            end,
    }
    valign_actions[element.valign]()

    cairo_move_to(display, element.from.x, element.from.y)
    cairo_rotate(display, element.rotation_angle * (math.pi / 180))

    cairo_show_text(display, element.text)
    cairo_stroke(display)
    cairo_restore(display)

    tolua.takeownership(extents)
    tolua.takeownership(metrics)
end
