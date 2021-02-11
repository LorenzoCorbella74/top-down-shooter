function createBulletHandler()

    local layer = map:addCustomLayer("bullets", 6)

    layer.bullets = {}

    layer.create = function(origin, angle, type)
        local bullet = {}
        if type == "machinegun" then
            bullet.sprite = love.graphics.newImage("myTiles/bullet1.png")
        end

        -- motion
        bullet.x = origin.x
        bullet.y = origin.y
        bullet.w = 16
        bullet.h = 16
        bullet.speed = 500
        bullet.dx = bullet.speed * math.cos(angle)
        bullet.dy = bullet.speed * math.sin(angle)
        -- state
        bullet.damage = 50 -- how much damange it deals
        bullet.timeout = 2 -- how many seconds before despawning

        world:add(bullet, bullet.x, bullet.y, bullet.w, bullet.h, layer.filter) -- bullets is in the phisycs world
        table.insert(layer.bullets, bullet)
    end

    layer.filter = function(other)
        local kind = other.class.name
        if kind == 'walls' then return "bounce" end
    end

    -- Update bullets
    layer.update = function(self, dt)
        for _i, bullet in ipairs(self.bullets) do

            -- update bullet positions
            local futurex = bullet.x + bullet.dx * dt
            local futurey = bullet.y + bullet.dy * dt

            bullet.x, bullet.y, cols, cols_len =
                world:move(bullet, futurex, futurey)

            -- collision with walls
            for i = 1, cols_len do
                local col = cols[i]
                local item = cols[i].other
                if (item.layer and item.layer.name == 'walls') then
                    table.remove(self.bullets, _i)
                    world:remove(bullet) -- powerup is no more in the phisycs world
                end
                print(("item = %s, type = %s, x,y = %d,%d"):format(
                          tostring(col), col.type, col.normal.x, col.normal.y))
            end

            -- remove bullets that have timed out
            if bullet.timeout > 0 then
                bullet.timeout = bullet.timeout - 1 * dt
            else
                if world:hasItem(bullet) then
                    table.remove(self.bullets, _i)
                    world:remove(bullet)
                else
                    print("Tried to remove already removed object: ")
                end
            end

        end
    end

    -- Draw bullets
    layer.draw = function(self)
        for k, object in pairs(self.bullets) do
            love.graphics.draw(object.sprite, math.floor(object.x),
                               math.floor(object.y), 0, 1, 1)
            --[[ love.graphics.rectangle("line", math.floor(object.x),
                               math.floor(object.y), object.w, object.h) ]]
        end
    end

    return layer
end

