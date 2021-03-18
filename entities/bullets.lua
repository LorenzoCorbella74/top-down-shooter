local BulletsHandler = {}

BulletsHandler.new = function()

    local self = map:addCustomLayer("bullets", 6)

    self.bullets = {}

    local bulletFilter = function(item, other)
        local kind = other.layer and other.layer.name or other
        if kind == 'walls' then
            return "bounce"
        elseif other.type == 'actor' then
            return 'cross'
        end
    end

    function self.calculatePoints(actor, damage)
        if actor.ap > 0 then
            actor.ap = actor.ap - damage;
            local what = actor.ap;
            if what < 0 then
                actor.hp = actor.hp + what
                actor.ap = 0
            end
        else
            actor.ap = 0;
            actor.hp = actor.hp - damage
        end
    end

    function self.calculateRanking()
        local index;
        table.sort(handlers.actors, function(a, b)
            return a.kills > b.kills
        end)
        for i = 1, #handlers.actors, 1 do
            local e = handlers.actors[i]
            if e.name == 'player' then
                index = i
                break
            end
        end
        local ranking = {
            [1] = '1st',
            [2] = '2nd',
            [3] = '3rd',
            [4] = '4th',
            [5] = '5th',
            [6] = '6th',
            [7] = '7th',
            [8] = '8th',
            [9] = '9th',
            [10] = '10th'
        }
        return ranking[index]
    end

    function self.create(origin, angle, who)
        local b = {}
        local w = who.weaponsInventory.selectedWeapon
        local sprite = w.sprite
        b.sprite = sprite
        b.w = sprite:getWidth()
        b.h = sprite:getHeight()
        b.firedBy = who
        -- motion
        b.x = origin.x
        b.y = origin.y
        b.r = angle
        b.speed = w.speed
        b.dx = b.speed * math.cos(angle)
        b.dy = b.speed * math.sin(angle)
        -- state
        b.ttl = w.ttl -- how many seconds before despawning
        b.damage = w.damage -- how much damange it deals

        world:add(b, b.x, b.y, b.w, b.h) -- bullet is in the phisycs world
        table.insert(self.bullets, b)
        w.shotNumber = w.shotNumber - 1
    end

    function self.update(self, dt)
        for _i = #self.bullets, 1, -1 do
            local bullet = self.bullets[_i]

            -- update bullet positions
            local futurex = bullet.x + bullet.dx * dt
            local futurey = bullet.y + bullet.dy * dt

            local cols, cols_len

            bullet.x, bullet.y, cols, cols_len =  world:move(bullet, futurex, futurey, bulletFilter)

            -- collisions
            for i = 1, cols_len do
                local col = cols[i]
                local item = cols[i].other
                -- impact with walls
                if (item.layer and item.layer.name == 'walls') then
                    world:remove(bullet) -- powerup is no more in the phisycs world
                    table.remove(self.bullets, _i)
                    break -- break after the first impact
                end
                -- impact with bots or player
                if (item.type and item.type == 'actor') then
                    -- create blood
                    -- red flash if player
                    if item.name == 'player' then
                        camera:flash(0.15, {1, 0, 0, 0.25})
                    end
                    world:remove(bullet)                -- bullet is no more in the phisycs world
                    table.remove(self.bullets, _i)      -- bullet is no more in the list of bullets
                    self.calculatePoints(item, bullet.damage);
                    if item.hp <= 0 then
                        bullet.firedBy.kills = bullet.firedBy.kills + 1 -- increase the score of who fired the bullet
                        -- sound death
                        if item.name == 'player' then
                            handlers.camera.setCameraOnActor(bullet.firedBy)
                            handlers.player.die()
                        else
                            handlers.bots.die(item)
                            handlers.ui.setMsg(
                                'You fragged ' .. item.name .. ' - ' ..
                                    self.calculateRanking() .. ' place with ' ..
                                    bullet.firedBy.kills)
                                    Timer.after(6, function() handlers.ui.setMsg('') end)
                        end
                    end
                    break -- break after the first impact
                end
                -- print(("item = %s, type = %s, x,y = %d,%d"):format(tostring(col), col.type, col.normal.x, col.normal.y))
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

    function self.draw(self)
        for _i = #self.bullets, 1, -1 do
            local bullet = self.bullets[_i]
            love.graphics.draw(bullet.sprite, math.floor(bullet.x + bullet.w / 2), math.floor(bullet.y + bullet.h / 2), bullet.r, 1, 1, bullet.w / 2, bullet.h / 2)
        end
    end

    return self

end

return BulletsHandler

