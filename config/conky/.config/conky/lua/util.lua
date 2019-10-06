--
-- util.lua
--

--
-- Execute external command and return stdout
--
function command(line)
    local file = io.popen(line)
    output = file:read("*a")
    file:close()
    return output
end

--
-- Execute external command and return result
--
function command_exec(line)
    local result = os.execute(line)
    return result
end

--
-- Tokenize string to given delimeter
--
function string:split(delimiter)
    s = self
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--
-- Convert color value to tuple of elements
--
function rgba_to_r_g_b_a(tcolor)
    local color, alpha = tcolor[1], tcolor[2]
    return ((color / 0x10000) % 0x100) / 255.,
           ((color / 0x100) % 0x100) / 255.,
           (color % 0x100) / 255.,
           alpha
end

function hexa_to_rgb(color, alpha)
    return ((color / 0x10000) % 0x100) / 255.,
           ((color / 0x100) % 0x100) / 255.,
           (color % 0x100) / 255.,
           alpha
end

--
-- Fetch color value using xcolor script
--
function xcolor(name)
    local cmd = "xcolor" .. " " .. name
    local stdout = command(cmd)
    local colstr = "0x" .. stdout:sub(2)
    return tonumber(colstr)
end

--
-- Evaluate a conky template to get its current value
--
--   Example: "cpu cpu0" --> 20
--
function conky_value(conky_value, is_number)
    local value = conky_parse(string.format('${%s}', conky_value))
    if is_number then
        value = tonumber(value)
    end
    if value == nil then
        return 0
    end
    return value
end

--
-- Check table has the required properties
--
function check_requirements(tbl, requirements)
    -- If there are defined requirements for that table
    if requirements ~= nil then
        -- Check all of them are defined by the user
        for i, property in pairs(requirements) do
            if tbl[property] == nil then
                error('Missing "' .. property .. '" value')
            end
        end
    end
end

--
-- Fill table with the missing values, using the defaults
--
function fill_defaults(tbl, defaults)
    -- Only if there are defined defaults for that element kind
    if defaults ~= nil then
        -- Fill the table with the defaults (for the properties without value)
        for key, value in pairs(defaults) do
            if tbl[key] == nil then
                tbl[key] = defaults[key]
            end
        end
    end
end

--
-- Re-usable entrypoint function
--
function main_common(update_fn)
    -- Check
    if conky_window == nil then
        return
    end

    -- Initialize
    local surface = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )
    local display = cairo_create(surface)

    -- Update
    local updates = tonumber(conky_parse('${updates}'))
    if updates > 3 then
        update_fn(display)
    end

    -- Destroy
    cairo_destroy(display)
    cairo_surface_destroy(surface)
    display = nil
end
