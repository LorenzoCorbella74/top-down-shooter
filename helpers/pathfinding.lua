local Grid = require("libs.jumper.grid") -- The grid class
local Pathfinder = require("libs.jumper.pathfinder") -- The pathfinder class

local PathfindHandler = {}

PathfindHandler.new = function(map_tiled, name, walkable, mode)
    local self = {}

    self.mode = ''
    self.data = {}
    self.walkable = 0
    self.starting_map = map_tiled

    if not (type(mode) == "string") then
        self.mode = 'JPS'
    else
        self.mode = mode
    end
    for _, layer in ipairs(self.starting_map.layers) do
        -- Entire layer
        if layer.properties.collidable == true and layer.name == name then
            self.data = layer.data
            self.walkable = walkable
            break
        end
    end

    self.collisionMap = {}
    -- rows
    for y = 1, self.starting_map.height do
        self.collisionMap[y] = {}
        -- columns
        for x = 1, self.starting_map.width do
            self.collisionMap[y][x] = self.data[(y - 1) *
                                          self.starting_map.width + (x)] == 0 and
                                          0 or 1
        end
    end
    -- print(self.collisionMap)

    -- return the path
    function self.calculatePath(xs, ys, xf, yf)
        -- Creates a grid object
        local grid = Grid(self.collisionMap)
        -- Creates a pathfinder object using Jump Point Search
        local myFinder = Pathfinder(grid, self.mode, self.walkable)
        -- myFinder:setHeuristic('EUCLIDIAN')
        -- myFinder:setHeuristic('DIAGONAL')
        -- myFinder:setHeuristic('MANHATTAN')
        local path = myFinder:getPath(xs, ys, xf, yf)
        return path
    end

    -- return the row and the column
    function self.worldToTile(x, y)
        local cols = math.floor(x / self.starting_map.tilewidth)
        local rows = math.floor(y / self.starting_map.tileheight)
        return cols, rows
    end

    function self.tileToWorld(x_tile, y_tile)
        local tx = x_tile * self.starting_map.tilewidth
        local ty = y_tile * self.starting_map.tileheight
        return tx, ty
    end

    return self
end

return PathfindHandler

