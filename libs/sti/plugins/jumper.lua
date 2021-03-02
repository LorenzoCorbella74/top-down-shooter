return {
    bump_LICENSE = "MIT/X11",
    bump_URL = "https://github.com/someonecool/bump_sti_plugin",
    bump_VERSION = "3.1.5.0", -- semantic versioning, this implies that it should work with bump 3.1.5 and has not yet been revised.
    bump_DESCRIPTION = "Box2D hooks for STI.",

    jumper_init = function(map, name, walkable, mode, Grid, Pathfinder)
        map.jumper = {}
        if not (type(mode) == "string") then
            map.jumper.mode = 'JPS'
        else
            map.jumper.mode = mode
        end
        for _, layer in ipairs(map.layers) do
            -- Entire layer
            if layer.properties.collidable == true and layer.name == name then
                map.jumper.data = layer.data
                map.jumper.walkable = walkable
                map.jumper.Grid = Grid
                map.jumper.Pathfinder = Pathfinder
                break
            end
        end
    end,

    -- return the path
    jumper_calculatePath = function(map, xs, ys, xf, yf)
        -- Creates a grid object
        local grid = map.jumper.Grid(map)
        -- Creates a pathfinder object using Jump Point Search
        local myFinder = map.jumper.Pathfinder(grid, map.jumper.mode,
                                               map.jumper.walkable)
        return myFinder
    end,

    -- return the row and the column
    jumper_getCoord = function(map, x, y)
        local width = map.width
        local height = map.height
        local px = math.floor(x / map.tilewidth)
        local py = math.floor(y / map.tileheight)
        return px, py
    end
}
