function createPlayer()
    local layer = map:addCustomLayer("Sprites", 4)

    -- Get player spawn object
    local player
    for k, object in pairs(map.objects) do
        print(k)
        if object.name == "spawn" then
            player = object
            break
        end
    end

    local playerFilter = function(item, other)
        if other.name == 'health' and other.visible then
            return 'cross'
        else
            return 'slide'
        end
    end

    -- Create player object
    local sprite = love.graphics.newImage("myTiles/tiles/21.png")

    layer.player = {
        sprite = sprite,
        x = player.x,
        y = player.y,
        w = sprite:getWidth(),
        h = sprite:getHeight(),

        cx = player.x + sprite:getWidth() / 2,
        cx = player.y + sprite:getHeight() / 2,

        r = 0,
        speed = 256, -- pixels per second

        -- bounding box

        hp = 100,
        ap = 0,

        kills = 0
    }

    world:add(layer.player, layer.player.x, layer.player.y, layer.player.w,
              layer.player.h) -- player is in the phisycs world

    -- Add controls to player
    layer.update = function(self, dt)
        local futurex = self.player.x
        local futurey = self.player.y
        -- Move player up
        if love.keyboard.isDown("w", "up") then
            futurey = self.player.y - self.player.speed * dt
        end

        -- Move player down
        if love.keyboard.isDown("s", "down") then
            futurey = self.player.y + self.player.speed * dt
        end

        -- Move player left
        if love.keyboard.isDown("a", "left") then
            futurex = self.player.x - self.player.speed * dt
        end

        -- Move player right
        if love.keyboard.isDown("d", "right") then
            futurex = self.player.x + self.player.speed * dt
        end

        local cols

        -- player rotation
        local mx, my = camera:getMousePosition()
        self.player.r = math.atan2(my - (self.player.y + self.player.h / 2),
                                   mx - (self.player.x + self.player.w / 2))

        -- trasformazione del bounding box in base alla rotazione

        -- update the player associated bounding box in the world
        self.player.x, self.player.y, cols, cols_len =
            world:move(self.player, futurex, futurey, playerFilter)
        for i = 1, cols_len do
            local item = cols[i].other
            local col = cols[i]
            if (item.name == 'health' and item.visible) then
                self.player.hp = self.player.hp + item.properties.points
                camera:shake(16, 1, 60)
                world:remove(item) -- powerup is no more in the phisycs world
                item.visible = false
            end

            print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(
                      col.other, col.type, col.normal.x, col.normal.y))
        end
    end

    -- Draw player
    layer.draw = function(self)
        -- love.graphics.draw(self.player.sprite, math.floor(self.player.x),math.floor(self.player.y), 0, 1, 1)
        love.graphics.draw(self.player.sprite,
                           math.floor(self.player.x + self.player.w / 2),
                           math.floor(self.player.y + self.player.h / 2),
                           self.player.r, 1, 1, self.player.w / 2,
                           self.player.h / 2)
    end

    return layer
end

