function createPowerUps()

    local layer = map:addCustomLayer("powerups", 5)

    layer.powerups = {}

    for k, object in pairs(map.objects) do
        if object.name == "health" then
            object.sprite = love.graphics.newImage("myTiles/tiles/24.png")
            object.inCheck = false
            object.visible = true
            table.insert(layer.powerups, object)
            world:add(object, object.x, object.y, object.width, object.height) -- powerups is in the phisycs world
        end
    end

    -- Update powerups
    layer.update = function(self, dt)
        for k, object in pairs(self.powerups) do
            if not object.visible and not object.inCheck then
                object.inCheck = true
                Timer.after(10, function() -- after 10 
                    object.inCheck = false
                    object.visible = true
                    world:add(object, object.x, object.y, object.width,
                              object.height) -- powerups is in the phisycs world again
                end)
            end
        end
    end

    -- Draw powerups
    layer.draw = function(self)
        for k, object in pairs(self.powerups) do
            if (object.visible) then
                love.graphics.draw(object.sprite, math.floor(object.x),
                                   math.floor(object.y), 0, 1, 1)
            end
        end
    end

    return layer
end

