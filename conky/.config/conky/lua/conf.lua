--
-- conf.lua
--

require 'util'

local color_table = {
    main = nil,
    altn = nil,
}

--
-- Read color reference for given alias
--
function color_ref(r)
    return command('colref ' .. r)
end

--
-- Read colors from environment to local variables
--
function config_load_colors()
    local u = { main = color_ref('main'), altn = color_ref('altn') }
    for k, v in pairs(u) do
        color_table[k] = xcolor(v)
    end
end

--
-- Fetch color with given role
--
function config_color(role)
    return color_table[role]
end

--
-- Refreshes configuration
--
function config_refresh()
    config_load_colors()
end

-- Initialize configuration
config_refresh()
