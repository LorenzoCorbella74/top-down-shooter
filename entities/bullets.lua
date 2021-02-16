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
        bullet.speed = 1000
        bullet.r = angle
        bullet.dx = bullet.speed * math.cos(angle)
        bullet.dy = bullet.speed * math.sin(angle)

        -- state
        bullet.damage = 50 -- how much damange it deals
        bullet.timeout = 2 -- how many seconds before despawning

        world:add(bullet, bullet.x, bullet.y, bullet.w, bullet.h) -- bullets is in the phisycs world
        table.insert(layer.bullets, bullet)
    end

    layer.filter = function(item, other)
        local kind = other.layer and other.layer.name or other
        print(('Kind:%s'):format(kind))
        if kind == 'walls' then
            return "bounce"
        else
            return 'slide'
        end
    end

    -- Update bullets
    layer.update = function(self, dt)
        for _i = #self.bullets, 1, -1 do
            local bullet = self.bullets[_i]

            -- update bullet positions
            local futurex = bullet.x + bullet.dx * dt
            local futurey = bullet.y + bullet.dy * dt

            bullet.x, bullet.y, cols, cols_len =
                world:move(bullet, futurex, futurey, layer.filter)

            -- collision with walls
            for i = 1, cols_len do
                local col = cols[i]
                local item = cols[i].other
                if (item.layer and item.layer.name == 'walls') then
                    world:remove(bullet) -- powerup is no more in the phisycs world
                    table.remove(self.bullets, _i)
                    break -- break after the first wall
                end
                print(("item = %s, type = %s, x,y = %d,%d"):format(
                          tostring(col), col.type, col.normal.x, col.normal.y))
            end

            -- remove bullets that have timed out
            if bullet.timeout > 0 then
                bullet.timeout = bullet.timeout - 1 * dt
            else
                if world:hasItem(bullet) then
                    world:remove(bullet)
                    table.remove(self.bullets, _i)
                else
                    print("Tried to remove already removed object: ")
                end
            end

        end
    end

    -- Draw bullets
    layer.draw = function(self)
        for _i = #self.bullets, 1, -1 do
            local bullet = self.bullets[_i]
            love.graphics.draw(bullet.sprite,
                               math.floor(bullet.x + bullet.w / 2),
                               math.floor(bullet.y + bullet.h / 2), bullet.r, 1, 1, bullet.w / 2, bullet.h / 2)
            --[[ love.graphics.rectangle("line", math.floor(bullet.x),
                               math.floor(bullet.y), bullet.w, bullet.h) ]]
        end
    end

    return layer
end

