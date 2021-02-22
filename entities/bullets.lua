function CreateBulletHandler()

    local layer = map:addCustomLayer("bullets", 6)

    layer.bullets = {}

    layer.create = function(origin, angle, currentWeapon)
        local bullet = {}
        local sprite = currentWeapon.sprite
        bullet.sprite = sprite
        bullet.w = sprite:getWidth()
        bullet.h = sprite:getHeight()
        -- motion
        bullet.x = origin.x
        bullet.y = origin.y
        bullet.r = angle
        bullet.speed = currentWeapon.speed
        bullet.dx = bullet.speed * math.cos(angle)
        bullet.dy = bullet.speed * math.sin(angle)
        -- state
        bullet.ttl = currentWeapon.ttl          -- how many seconds before despawning
        bullet.damage = currentWeapon.damage -- how much damange it deals

        world:add(bullet, bullet.x, bullet.y, bullet.w, bullet.h) -- bullets is in the phisycs world
        table.insert(layer.bullets, bullet)
        currentWeapon.shotNumber = currentWeapon.shotNumber -1
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

            local cols, cols_len

            bullet.x, bullet.y, cols, cols_len = world:move(bullet, futurex, futurey, layer.filter)

            -- collisions
            for i = 1, cols_len do
                local col = cols[i]
                local item = cols[i].other
                -- with walls
                if (item.layer and item.layer.name == 'walls') then
                    world:remove(bullet) -- powerup is no more in the phisycs world
                    table.remove(self.bullets, _i)
                    break -- break after the first wall
                end
                -- impact on bot or player
                --[[ if (item.layer and item.layer.name == 'walls') then
                    world:remove(bullet) -- powerup is no more in the phisycs world
                    table.remove(self.bullets, _i)
                    break -- break after the first wall
                end ]]
                print(("item = %s, type = %s, x,y = %d,%d"):format(tostring(col), col.type, col.normal.x, col.normal.y))
            end

            -- remove bullets that have timed out
            if bullet.ttl > 0 then
                bullet.ttl = bullet.ttl - 1 * dt
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

