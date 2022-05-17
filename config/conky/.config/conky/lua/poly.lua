--
-- poly.lua
--

-- Extend package search to directory of current script
current_path = debug.getinfo(1).source:match("@?(.*/)")
package.path = current_path .. "?.lua;" .. package.path

require 'cairo'
require 'util'

--------------------------------------------------------------------------------------------
scale = 2
width = 640
height = 480

function draw_line(x1, y1, x2, y2, size)
    cairo_set_line_width(cr, size);
    cairo_move_to(cr, x1, y1);
    cairo_line_to(cr, x2, y2);
    cairo_stroke(cr);
end

function draw_point(x, y, size)
    cairo_arc(cr, x, y, size, 0, 2 * math.pi);
    cairo_fill(cr);
end

function rotate_x(p, angle)
    local c = math.cos(angle);
    local s = math.sin(angle);
    matrix = {
        {1, 0, 0},
        {0, c,-s},
        {0, s, c}
    };
    return matrix_vector_product(matrix, p);
end

function rotate_y(p, angle)
    local c = math.cos(angle);
    local s = math.sin(angle);
    matrix = {
        { c, 0, s},
        { 0, 1, 0},
        {-s, 0, c}
    };
    return matrix_vector_product(matrix, p);
end

function rotate_z(p, angle)
    local c = math.cos(angle);
    local s = math.sin(angle);
    matrix = {
        {c,-s, 0},
        {s, c, 0},
        {0, 0, 1}
    };
    return matrix_vector_product(matrix, p);
end

function matrix_vector_product(matrix, vector)
    local result = {}
    for i, row in pairs(matrix) do
        result[i] = 0;
        for j, v in pairs(vector) do
            result[i] = result[i] + row[j]*v;
        end
    end
    return result;
end

function draw_dodecahedron(cx, cy, radius)
    local point_size = 10;
    local line_size = 4;
    local q = 0.577350269;
    local t = 0.934172359;
    local y = 0.35682209;

    -- (±1,  ±1,  ±1)
    -- ( 0,  ±ϕ,  ±1/ϕ)
    -- (±1/ϕ, 0,  ±ϕ)
    -- (±ϕ,  ±1/ϕ, 0)

    local vertices = {
        { q, q, q},
        { q, q,-q},
        { q,-q, q},
        { q,-q,-q},
        {-q, q, q},
        {-q, q,-q},
        {-q,-q, q},
        {-q,-q,-q},

        { 0, t, y},
        { 0, t,-y},
        { 0,-t, y},
        { 0,-t,-y},

        { y, 0, t},
        { y, 0,-t},
        {-y, 0, t},
        {-y, 0,-t},

        { t, y, 0},
        { t,-y, 0},
        {-t, y, 0},
        {-t,-y, 0},

    };

    local edges = {
        {1, 9},  {1, 13}, {1, 17},
        {2, 10}, {2, 14}, {2, 17},
        {3, 11}, {3, 13}, {3, 18},
        {4, 12}, {4, 14}, {4, 18},
        {5, 9},  {5, 15}, {5, 19},
        {6, 10}, {6, 16}, {6, 19},
        {7, 11}, {7, 15}, {7, 20},
        {8, 12}, {8, 16}, {8, 20},

        {9, 10},
        {11, 12},

        {17, 18},
        {19, 20},

        {13, 15},
        {14, 16},
    };

    draw_mesh(cx, cy, vertices, edges, radius, 0x7c, 0x9f, 0xa6, 100);
end

function draw_tetrahedron(cx, cy, radius)
    local point_size = 10;
    local line_size = 4;
    local q = 0.57735026919; -- bound coordinates to the unit circle

    local vertices = {
        { q, q, q},
        { q,-q,-q},
        {-q, q,-q},
        {-q,-q, q}
    };

    local edges = {
        {1, 2},
        {1, 3},
        {1, 4},
        {2, 3},
        {3, 4},
        {4, 2}
    };

    draw_mesh(cx, cy, vertices, edges, radius, 0x7c, 0x9f, 0xa6, 200);
end

function draw_icosahedron(cx, cy, radius)
    local q = 0.5663; -- bound coordinates to the unit circle
    local w = 0.916320109; -- bound coordinates to the unit circle
    local vertices = {
        { 0, q, w},
        { q, w, 0},
        { w, 0, q},
        { 0,-q, w},
        {-q, w, 0},
        { w, 0,-q},
        { 0, q,-w},
        { q,-w, 0},
        {-w, 0, q},
        { 0,-q,-w},
        {-q,-w, 0},
        {-w, 0,-q}
    };
    local edges = {
        {1, 2}, {2, 3},
        {1, 3}, {3, 4},
        {1, 4}, {4, 9},
        {1, 9}, {9, 5},
        {1, 5}, {5, 2},

        {6, 2},  {2, 3},
        {6, 3},  {3, 8},
        {6, 8},  {8, 10},
        {6, 10}, {10, 7},
        {6, 7},  {7, 2},

        {11, 4},  {4,  8},
        {11, 8},  {8,  10},
        {11, 10}, {10, 12},
        {11, 12}, {12, 9},
        {11, 9},  {9,  4},

        {12, 5},
        {12, 7},
        {5, 7},
    };
    draw_mesh(cx, cy, vertices, edges, radius, 0x7c, 0x9f, 0xa6, 300);
end

function draw_mesh(x, y, vertices, edges, scale, r, g, b, time_offset)
    local point_size = 8 * scale / (height / 8);
    local line_size = 4;

    for index, point in pairs(vertices) do
        point = rotate_x(point,(t+time_offset)/2);
        point = rotate_y(point,(t+time_offset)/3);
        point = rotate_z(point,(t+time_offset)/5);
        vertices[index] = point;

        local shade_amount = (point[3] > 0 and 0 or -point[3] * .5);
        cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1 - shade_amount);
        -- cairo_set_source_rgba(cr, r/0xff, g/0xff, b/0xff, 1);

        draw_point(x+point[1]*scale, y+point[2]*scale, point_size);
    end

    for index, line in pairs(edges) do
        z = vertices[line[1]][3] + vertices[line[2]][3] / 2;
        local shade_amount = (z > 0 and 0 or -z * .5);
        cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1 - shade_amount);
        -- cairo_set_source_rgba(cr, r/0xff, g/0xff, b/0xff, 1);

        draw_line(x + vertices[line[1]][1] * scale, y + vertices[line[1]][2] * scale,
                  x + vertices[line[2]][1] * scale, y + vertices[line[2]][2] * scale,
                  line_size);
    end
end

function test_3d(display)
    cr = display
    cairo_set_source_rgba(display, 0.933, 0.905, 0.894, 1)

    local updates = tonumber(conky_parse('${updates}'));
    updates_pr_second = 1 / conky_info["update_interval"];
    t = conky_info["update_interval"] * updates
    period = 1;
    --t = t/10;

    --local volume = tonumber(conky_parse('${exec amixer sget Master | grep -o_pm 1 [0-9]+% | grep -o_p [0-9]+}'));
    --local battery = tonumber(conky_parse('${exec acpi | grep -o_pm 1 [0-9]+% | grep -o_p [0-9]+}'));
    --local brightness = tonumber(conky_parse('${exec light | grep -o_p ^[0-9]+}'));

    local volume = 40;
    local battery = 40;
    local brightness = 40;

    local cy, radius = height / 2, height / 4;

    --draw_tetrahedron(width  / 4 * 1, cy, radius * .1 + radius * .9 * battery / 100);
    --draw_dodecahedron(width / 4 * 2, cy, radius * .1 + radius * .9 * brightness / 100);
    --draw_icosahedron(width  / 4 * 3, cy, radius * .1 + radius * .9 * volume / 100);

    draw_icosahedron(width/4 * 2, cy, radius * .1 + radius * .9 * volume/100);
end
--------------------------------------------------------------------------------------------

function poly_main(display)
    test_3d(display)
end

-- Alias for conky config to find it
conky_poly_main = function()
    main_common(poly_main)
end
