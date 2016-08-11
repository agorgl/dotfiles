require 'cairo'

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
    local title = "SYS LOGS"
    local cmd = "journalctl -b -e | cut -d\" \" -f3,5- | cut -c1-83 | tail -n 15"
    logwidget(cr, title, cmd)
    --
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr = nil
end
