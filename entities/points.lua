local PointsHandler = {}

PointsHandler.new = function()

    local self = {}

    self.spawnPoints = {}
    self.waypoints = {}



    function self.getPointsFromMap()
        for k, object in pairs(map.objects) do
            -- spawnpoints
            if object.name == "spawn" then
                object.used = false
                object.w = object.width
                object.h = object.height
                object.orientation = math.rad(object.properties.orientation)
                table.insert(self.spawnPoints, object)
            end
            -- bots' waypoints
            if object.name == "waypoint" then
                object.w = object.width
                object.h = object.height
                object.inCheck = false
                object.objective = object.properties.objective
                world:add(object, object.x, object.y, object.width, object.height)
                table.insert(self.waypoints, object)
            end
        end
    end

    function self.getRandomSpawnPoint()
        -- indices used
        local indices = {}
        for index, item in ipairs(self.spawnPoints) do
            if item.used == false then table.insert(indices, item) end
        end
        local randomIndex = math.random(1, #indices)
        local choosen = self.spawnPoints[randomIndex]
        choosen.used = true
        Timer.after(3, function() choosen.used = false end)
        return choosen.x, choosen.y, choosen.orientation
    end

    -- waypoint visibility for each bot
    -- when it's taken it's no more visible and a timer is called
    -- after x sec the waypoint is once again visible
    function self.seedBotsInWaypoints(bots)
        for i = #self.waypoints, 1, -1 do
            local waypoints = self.waypoints[i]
            waypoints.bots = {}
            for y = #bots, 1, -1 do
                local bot = bots[y]
                waypoints.bots[bot.index] = {visible = true}  -- index o name ???
            end
        end
    end

    return self
end

return PointsHandler
