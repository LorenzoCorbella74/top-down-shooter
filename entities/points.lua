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
                object.angle = object.properties.angle
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
        Timer.after(0.1, function() choosen.used = false end)
        return choosen.x, choosen.y, choosen.orientation
    end

    -- waypoint visibility for each bot
    -- when it's taken it's no more visible and a timer is called
    -- after x sec the waypoint is once again visible
    function self.seedBotsInWaypoints(players)
        for i = #self.waypoints, 1, -1 do
            local waypoint = self.waypoints[i]
            if waypoint.type ~='defence' or waypoint.type~='target'  then
                waypoint.players = {}
                for y = #players, 1, -1 do
                    local player = players[y]
                    waypoint.players[player.index] = {visible = true}
                end
            end
        end
    end

    return self
end

return PointsHandler
