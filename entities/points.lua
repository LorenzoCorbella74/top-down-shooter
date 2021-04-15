local config = require "config"

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
            if item.used == false then table.insert(indices, index) end
        end
        local randomIndex = indices[math.random(1, #indices)]
        local choosen = self.spawnPoints[randomIndex]
        choosen.used = true
        Timer.after(0.1, function() choosen.used = false end)
        return choosen.x, choosen.y, choosen.orientation
    end

    -- waypoint visibility for each bot
    -- when it's taken it's no more crossable and a timer is called
    -- after x sec the waypoint is once again crossable
    function self.seedBotsInWaypoints(players)
        for i = #self.waypoints, 1, -1 do
            local waypoint = self.waypoints[i]
            waypoint.players = {}
            for y = #players, 1, -1 do
                local player = players[y]
                waypoint.players[player.index] = {visible = true}
            end
        end
    end

    function self.trackBot(id, bot)
        for i = #self.waypoints, 1, -1 do
            local waypoint = self.waypoints[i]
            if waypoint.id == id then
                waypoint.players[bot.index].visible = false
                Timer.after(config.GAME.WAYPOINTS_TIMING, function()
                    waypoint.players[bot.index].visible = true
                end)
            end
        end
    end

    return self
end

return PointsHandler
