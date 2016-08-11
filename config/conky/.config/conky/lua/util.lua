function command(line)
    local file = io.popen(line)
    output = file:read("*a")
    file:close()
    return output
end

function string:split(delimiter)
    s = self
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function rgba_to_r_g_b_a(tcolor)
    local color,alpha=tcolor[1],tcolor[2]
    return ((color / 0x10000) % 0x100) / 255.,
           ((color / 0x100) % 0x100) / 255.,
           (color % 0x100) / 255.,
           alpha
end
