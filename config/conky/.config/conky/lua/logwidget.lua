-- logwidget.lua

-- Config
LOG_WIDGET_HEADER_FONT = "hack"
LOG_WIDGET_HEADER_SIZE = 18
LOG_WIDGET_HEADER_COLOR = {0xa5adff, 0xFF}
LOG_WIDGET_CONTENT_FONT = "hack"
LOG_WIDGET_CONTENT_SIZE = 9
LOG_WIDGET_CONTENT_COLOR = {0x796a7b, 0xFF}

local function logwidget_set_font_options(cr)
    -- Font options
    local fnt_opts
    fnt_opts = cairo_font_options_create()
    cairo_font_options_set_antialias(fnt_opts, CAIRO_ANTIALIAS_BEST)
    cairo_font_options_set_hint_style(fnt_opts, CAIRO_HINT_STYLE_FULL)
    cairo_font_options_set_hint_metrics(fnt_opts, CAIRO_HINT_METRICS_ON)
    cairo_set_font_options(cr, fnt_opts)
    cairo_font_options_destroy(fnt_opts)
end

-- Returns bottom left corner of header
function logwidget_header(cr, title, xpos, ypos)
    -- Header opts
    local header_text = title
    cairo_select_font_face(cr, LOG_WIDGET_HEADER_FONT, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, LOG_WIDGET_HEADER_SIZE)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(LOG_WIDGET_HEADER_COLOR))

    -- Calculate text decoration positioning
    -- Members: x_bearing y_bearing width height x_advance y_advance
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, header_text, extents)

    --
    -- Draw decoration
    --
    -- Options
    local h = extents.height
    local w = extents.width
    local xb = extents.x_bearing
    local yb = extents.y_bearing
    local ll = 5
    local hpad = 20
    local vpad = 10
    cairo_set_line_width(cr, 1)

    -- tl
    cairo_move_to(cr, xpos, ypos - h - vpad)
    cairo_rel_line_to(cr, ll, 0)
    cairo_move_to(cr, xpos, ypos - h - vpad)
    cairo_rel_line_to(cr, 0, ll)
    -- tr
    cairo_move_to(cr, xpos + w + hpad, ypos - h - vpad)
    cairo_rel_line_to(cr, -ll, 0)
    cairo_move_to(cr, xpos + w + hpad, ypos - h - vpad)
    cairo_rel_line_to(cr, 0, ll)
    -- bl
    cairo_move_to(cr, xpos, ypos + vpad)
    cairo_rel_line_to(cr, ll, 0)
    cairo_move_to(cr, xpos, ypos + vpad)
    cairo_rel_line_to(cr, 0, -ll)
    -- br
    cairo_move_to(cr, xpos + w + hpad, ypos + vpad)
    cairo_rel_line_to(cr, -ll, 0)
    cairo_move_to(cr, xpos + w + hpad, ypos + vpad)
    cairo_rel_line_to(cr, 0, -ll)
    cairo_stroke(cr)

    -- Draw header text
    cairo_move_to(cr, xpos + hpad / 2, ypos)
    cairo_show_text(cr, header_text)
    cairo_stroke(cr)

    -- Return bottom left
    return xpos, ypos + h + vpad
end

function logwidget(cr, title, content)
    -- Setup common font options
    logwidget_set_font_options(cr)
    -- Initial positioning
    local xpos, ypos = 5, 30
    -- Draw header
    xpos, ypos = logwidget_header(cr, title, xpos, ypos)
    -- Syslog opts
    cairo_select_font_face(cr, LOG_WIDGET_CONTENT_FONT, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, LOG_WIDGET_CONTENT_SIZE)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(LOG_WIDGET_CONTENT_COLOR))
    -- Split contents to lines
    local lines = content:split("\n")
    -- Draw text
    ypos = ypos + 2
    cairo_move_to(cr, xpos, ypos)
    for i, line in ipairs(lines) do
        -- Draw line
        cairo_show_text(cr, line)
        cairo_stroke(cr)
        -- Calc position to next line
        local extents = cairo_text_extents_t:create()
        cairo_text_extents(cr, line, extents)
        -- Newline
        --local line_advance = extents.height -- Normal
        local line_advance = LOG_WIDGET_CONTENT_SIZE + 3 -- Monospace
        ypos = ypos + line_advance
        cairo_move_to(cr, xpos, ypos)
    end
end
