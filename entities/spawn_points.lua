local SpawnPointsHandler = {}

SpawnPointsHandler.new = function()

    local self = {}

    self.spawnPoints = {}
    self.waypoints = {}

    function self.getPointsFromMap()
        for k, object in pairs(map.objects) do
            -- spawnpoints
            if object.name == "spawn" then
                object.used = false
                object.orientation = math.rad(object.properties.orientation)
                table.insert(self.spawnPoints, object)
            end
            -- bots' waypoints
            if object.name == "waypoint" then
                object.objective = object.properties.objective
                table.insert(self.waypoints, object)
            end
        end
    end

    function self.getRandomSpawnPoint()
        local indices = {}
        for index, item in ipairs(self.spawnPoints) do
            if item.used == false then
                table.insert(indices, item)
            end
        end
        local randomIndex = math.random(1, #indices)
        local choosen = self.spawnPoints[randomIndex]
        choosen.used = true
        Timer.after(1, function()
            choosen.used = false
        end)
        return choosen.x, choosen.y, choosen.orientation
    end

    return self
end

return SpawnPointsHandler
