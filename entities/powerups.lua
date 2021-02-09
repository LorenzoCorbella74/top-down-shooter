local layer = map:addCustomLayer("powerups", 5)

layer.powerups = {}

for k, object in pairs(map.objects) do
    if object.name == "health" then
        object.sprite = love.graphics.newImage("myTiles/tiles/24.png")
        object.timer = 0
        object.visible = true
        table.insert(layer.powerups, object)
        world:add(object, object.x, object.y, object.width, object.height) -- player is in the phisycs world
    end
end

-- Update powerups
layer.update = function(self, dt)
    for k, object in pairs(layer.powerups) do
        if not object.visible then
            object.timer = object.timer + dt
            if object.timer > 10 then -- 10 sec to respawn
                object.visible = true
                world:add(object, object.x, object.y, object.width, object.height) -- player is in the phisycs world
                object.timer = 0
            end
        end
    end
end

-- Draw powerups
layer.draw = function(self)
    for k, object in pairs(layer.powerups) do
        if (object.visible) then
            love.graphics.draw(object.sprite, math.floor(object.x),math.floor(object.y), 0, 1, 1)
        end
    end
end

return layer
