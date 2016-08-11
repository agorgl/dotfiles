require 'cairo'

-- Returns bottom left corner of header
function syslog_header(cr, xpos, ypos)
    -- Header opts
    local header_text = "SYS LOGS"
    local header_text_sz = 18
    local header_font = "mono"
    local header_font_slant = CAIRO_FONT_SLANT_NORMAL
    local header_font_weight = CAIRO_FONT_WEIGHT_NORMAL
    local header_font_col = {0xa5adff, 0xFF}
    cairo_select_font_face(cr, header_font, header_font_slant, header_font_weight)
    cairo_set_font_size(cr, header_text_sz)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(header_font_col))
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

function syslog(cr)
    -- Initial positioning
    local xpos, ypos = 5, 30
    -- Draw header
    xpos, ypos = syslog_header(cr, xpos, ypos)
    -- Syslog opts
    local syslog_text_sz = 10
    local syslog_font = "mono"
    local syslog_font_slant = CAIRO_FONT_SLANT_NORMAL
    local syslog_font_weight = CAIRO_FONT_WEIGHT_NORMAL
    --local syslog_font_col = {0x494a5b, 0xFF}
    local syslog_font_col = {0x796a7b, 0xFF}
    cairo_select_font_face(cr, syslog_font, syslog_font_slant, syslog_font_weight)
    cairo_set_font_size(cr, syslog_text_sz)
    cairo_set_source_rgba(cr, rgba_to_r_g_b_a(syslog_font_col))
    -- Execute command and gather output
    local stdout = command("journalctl -b -e | cut -d\" \" -f3,5- | cut -c1-83 | tail -n 15")
    local lines = stdout:split("\n")
    -- Draw text
    cairo_move_to(cr, xpos, ypos)
    for i, line in ipairs(lines) do
        -- Draw line
        cairo_show_text(cr, line)
        cairo_stroke(cr)
        -- Calc position to next line
        local extents = cairo_text_extents_t:create()
        cairo_text_extents(cr, line, extents)
        -- Newline
        ypos = ypos + extents.height + 2
        cairo_move_to(cr, xpos, ypos)
    end
end

function conky_draw_main()
    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )
    cr = cairo_create(cs)
    local updates = tonumber(conky_parse('${updates}'))
    if updates > 5 then
        -- print("Hello world")
    end
    --
    syslog(cr)
    --
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr = nil
end
