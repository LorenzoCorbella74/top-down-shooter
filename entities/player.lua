require "..helpers.boundingbox"

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
    local sprite = love.graphics.newImage("myTiles/player.png")

    layer.player = {
        sprite = sprite,
        x = player.x,
        y = player.y,
        w = sprite:getWidth(),
        h = sprite:getHeight(),

        r = 0, -- rotation angle (radians)
        bb = {},
        speed = 256, -- pixels per second

        hp = 100,
        ap = 0,

        kills = 0
    }

    -- world:add(layer.player, layer.player.x, layer.player.y, layer.player.w, layer.player.h) -- player is in the phisycs world

    -- world:add(layer.player, layer.player.x, layer.player.y, layer.player.w,layer.player.h) -- player is in the phisycs world
    local bx, by, bw, bh = transformBoudingBox(layer.player.r, layer.player.x,
                                               layer.player.y, layer.player.w,
                                               layer.player.h)
    local p = layer.player.bb
    p.x = bx
    p.y = by
    p.w = bw
    p.h = bh
    world:add(p, p.x, p.y, p.w, p.h) -- player is in the phisycs world

    -- Add controls to player
    layer.update = function(self, dt)

        local p = self.player.bb
        local futurex = p.x
        local futurey = p.y
        -- Move player up
        if love.keyboard.isDown("w", "up") then
            futurey = p.y - self.player.speed * dt
        end

        -- Move player down
        if love.keyboard.isDown("s", "down") then
            futurey = p.y + self.player.speed * dt
        end

        -- Move player left
        if love.keyboard.isDown("a", "left") then
            futurex = p.x - self.player.speed * dt
        end

        -- Move player right
        if love.keyboard.isDown("d", "right") then
            futurex = p.x + self.player.speed * dt
        end

        -- player rotation
        local mx, my = camera:getMousePosition()
        self.player.r = math.atan2(my - self.player.y, mx - self.player.x)

        print(self.player.r)

        -- trasformazione del bounding box in base alla rotazione
        local bx, by, bw, bh = transformBoudingBox(self.player.r, self.player.x,
                                                   self.player.y, self.player.w,
                                                   self.player.h)
        p.x = bx
        p.y = by
        p.w = bw
        p.h = bh
        world:update(p, p.x, p.y, p.w, p.h) -- player is in the phisycs world

        local cols, cols_len
        -- update the player associated bounding box in the world
        p.x, p.y, cols, cols_len = world:move(p, futurex, futurey, playerFilter)

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

    layer.draw = function(self)
        -- Draw player
        local p = self.player
        love.graphics.draw(p.sprite, p.x, p.y, p.r, 1, 1, p.w / 2, p.h / 2)
        -- Bounding box
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.rectangle('line', p.bb.x, p.bb.y, p.bb.w, p.bb.h)
    end

    return layer
end

