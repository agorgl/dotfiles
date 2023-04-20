--
-- conf.lua
--

require 'util'

local color_table = {
    main = nil,
    altn = nil,
}

--
-- Read colors from environment to local variables
--
function config_load_colors()
    local u = { 'main', 'altn' }
    for _, v in ipairs(u) do
        color_table[v] = xcolor(v)
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
