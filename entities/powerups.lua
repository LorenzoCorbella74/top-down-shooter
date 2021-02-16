function createPowerUps()

    local layer = map:addCustomLayer("powerups", 5)

    layer.powerups = {}

    for k, object in pairs(map.objects) do
        if object.name == "health" then
            object.sprite = love.graphics.newImage("myTiles/tiles/24.png")
            object.inCheck = false
            object.visible = true
            world:add(object, object.x, object.y, object.width, object.height) -- powerups is in the phisycs world
            table.insert(layer.powerups, object)
        end
    end

    -- Update powerups
    layer.update = function(self, dt)
        for i = #self.powerups, 1, -1 do
            local object = self.powerups[i]
            if not object.visible and not object.inCheck then
                object.inCheck = true
                Timer.after(10, function() -- after 10 respawn
                    world:add(object, object.x, object.y, object.width,  object.height) -- powerups is in the phisycs world again
                    object.inCheck = false
                    object.visible = true
                end)
            end
        end
    end

    -- Draw powerups
    layer.draw = function(self)
        for k, object in pairs(layer.powerups) do
            if (object.visible) then
                love.graphics.draw(object.sprite, math.floor(object.x),  math.floor(object.y), 0, 1, 1)
            end
        end
    end

--[[     layer.onMessage = function(msg)
        for k, powerup in pairs(layer.powerups) do
            if (powerup == msg.to and msg.type == 'contact') then
                camera:shake(16, 1, 60)
                world:remove(msg.to) -- powerup is no more in the phisycs world
                powerup.visible = false
            end
        end
    end ]]

    return layer
end

