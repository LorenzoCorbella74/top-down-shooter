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
        bb = {}, -- bounding box
        speed = 256, -- pixels per second

        hp = 100,
        ap = 0,

        kills = 0
    }

    local bx, by, bw, bh = transformBoudingBox(layer.player.r,
                                               (layer.player.x + layer.player.w /
                                                   2), (layer.player.y +
                                                   layer.player.h / 2),
                                               layer.player.w, layer.player.h)

    layer.player.bb.x = bx
    layer.player.bb.y = by
    layer.player.bb.w = bw
    layer.player.bb.h = bh

    world:add(layer.player, bx, by, bw, bh) -- player bb is in the phisycs world

    -- Add controls to player
    layer.update = function(self, dt)

        local p = self.player
        local futurex = p.x
        local futurey = p.y
        -- Move player up
        if love.keyboard.isDown("w", "up") then
            futurey = p.y - p.speed * dt
        end

        -- Move player down
        if love.keyboard.isDown("s", "down") then
            futurey = p.y + p.speed * dt
        end

        -- Move player left
        if love.keyboard.isDown("a", "left") then
            futurex = p.x - p.speed * dt
        end

        -- Move player right
        if love.keyboard.isDown("d", "right") then
            futurex = p.x + p.speed * dt
        end

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

        -- apply first update to BB
        local ix, iy, iw, ih = world:getRect(p)
        world:update(p, ix, iy, iw, ih)

        -- player rotation
        local mx, my = camera:getMousePosition()
        p.r = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))

        -- trasformazione del bounding box in base alla rotazione
        local bx, by, bw, bh = transformBoudingBox(p.r, p.x + p.w / 2, p.y + p.h / 2, p.w, p.h)

        p.bb.x = bx
        p.bb.y = by
        p.bb.w = bw
        p.bb.h = bh

        world:update(p, bx, by, bw, bh) -- player is in the phisycs world
--[[ 
        local cols, cols_len
        -- update the player associated bounding box in the world
        p.x, p.y, cols, cols_len = world:move(p, p.x, p.y, playerFilter) ]]
    end

    layer.draw = function(self)
        -- Draw player
        local p = self.player
        local mx, my = camera:getMousePosition()
        love.graphics.draw(p.sprite, p.x + p.w / 2, p.y + p.h / 2, p.r, 1, 1,
                           p.w / 2, p.h / 2)

        -- cursor
        love.graphics.line(mx, my - 16, mx, my + 16)
        love.graphics.line(mx - 16, my, mx + 16, my)

        if debug then
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle('line', p.x, p.y, p.w, p.h)
            -- Bounding box
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.rectangle('line', p.bb.x, p.bb.y, p.bb.w, p.bb.h)

            -- line to cursor
            love.graphics.line(p.x + p.w / 2, p.y + p.h / 2, mx, my) -- origin is NOT moved
        end

        if debug then
            love.graphics.setColor(1, 1, 1, 1)
            local items, len = world:getItems()
            for i = 1, len do
                local x, y, w, h = world:getRect(items[i])
                -- local cx, cy = camera:toWorldCoords(x, y)
                love.graphics.rectangle("line", x, y, w, h)
            end
        end

    end

    return layer
end

