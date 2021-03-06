local config = require "config"
local BulletsHandler = {}

BulletsHandler.new = function()

    local self = map:addCustomLayer("bullets", 6)

    self.bullets = {}

    self.impacts = {}

    local bulletFilter = function(item, other)
        local kind = other.layer and other.layer.name or other
        if kind == 'walls' then
            return "bounce"
        elseif other.type == 'actor' then
            return 'cross'
        end
    end

    function self.createSmokeTrail()
        local impact = love.graphics.newParticleSystem(Sprites.particle_debris, 32)
        impact:setParticleLifetime(1, 2)
        impact:setLinearAcceleration(10, 10, 20, 20)
        impact:setEmissionRate(30)
        impact:setSpeed(10, 50)
        impact:setSizes(1)
        return impact
    end

    function self.createBulletImpactWith(mode, source)
        local img = mode=='wall' and Sprites.particle_debris or Sprites.particle_blood
        local size = mode=='wall' and 18 or 12
        local impact = love.graphics.newParticleSystem(img, 32)
        impact:setParticleLifetime(0.01, 0.5)
        impact:setLinearAcceleration(100, 100, 200, 200)
        impact:setSpeed(100,200)
        impact:setSizes(0.5,1)
        impact:setDirection(source.r-math.rad(180))
        local ox = source.x + source.w/2
        local oy = source.y + source.h/2
        impact:setPosition(ox,oy)
        impact:emit(size)
        table.insert(self.impacts, impact)
        return impact
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
            [10] = '10th',
            [11] = '11th',
            [12] = '12th'
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
        b.dx = b.speed * math.cos(angle + math.random() * w.spread - w.spread)
        b.dy = b.speed * math.sin(angle + math.random() * w.spread - w.spread)
        -- state
        b.ttl = w.ttl       -- how many seconds before despawning
        b.damage = w.damage -- how much damange it deals
        b.of = w.name       -- reference of the weapon

        if b.of=='Rocket' then
            b.pSystem = self.createSmokeTrail()
        end
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
            
            bullet.x, bullet.y, cols, cols_len = world:move(bullet, futurex, futurey, bulletFilter)
            -- smoke trail for rocket
            if bullet.of=='Rocket' then
                bullet.pSystem:setPosition(futurex + bullet.w/2,futurey + bullet.h/2)
                bullet.pSystem:setDirection(bullet.r-math.rad(180))
                bullet.pSystem:update(dt)
            end
            -- collisions
            for i = 1, cols_len do
                local col = cols[i]
                local item = cols[i].other
                -- impact with walls
                if (item.layer and item.layer.name == 'walls') then
                    -- Sound:play('Collisions', 'hits')
                    local impact = self.createBulletImpactWith('wall', bullet)  -- debris particles
                    world:remove(bullet) -- powerup is no more in the phisycs world
                    table.remove(self.bullets, _i)
                    break -- break after the first impact
                end
                -- impact with bots or player
                if (item.type and item.type == 'actor') then
                    Sound:play('hits', 'hits')
                    local impact = self.createBulletImpactWith('enemy', bullet) -- blood particles
                    item.underAttack = true
                    item.underAttackPoint = col.touch
                    -- red flash if player
                    if item.name == 'player' then
                        camera:flash(0.15, {1, 0, 0, 0.25})
                    end
                    world:remove(bullet)                -- bullet is no more in the phisycs world
                    table.remove(self.bullets, _i)      -- bullet is no more in the list of bullets
                    self.calculatePoints(item, bullet.damage);
                    if item.hp <= 0 then
                        Sound:play('death', 'hits')
                        -- create blood pool
                        local origin = bullet.firedBy
                        if config.GAME.MATCH_TYPE=='deathmatch' then
                            origin.kills = origin.kills + 1 -- increase the score of who fired the bullet
                        elseif config.GAME.MATCH_TYPE=='team_deathmatch' then
                            origin.teamStatus[origin.team].score = origin.teamStatus[origin.team].score + 1
                        end

                        -- sound death
                        if item.name == 'player' then
                            handlers.camera.setCameraOnActor(origin)
                            handlers.player.die()
                            local count = config.GAME.RESPAWN_TIME
                            -- countdown for player
                            local countdown = Timer.every(1, function() 
                                count = count - 1
                                handlers.ui.setMsg('Respawn in '.. count)
                            end, config.GAME.RESPAWN_TIME)
                            Timer.after(config.GAME.RESPAWN_TIME, function()
                                Timer.cancel(countdown)
                                handlers.ui.setMsg('')
                            end)
                        else
                            handlers.bots.die(item)
                            if origin.name =='player' then
                                handlers.ui.setMsg(
                                    'You fragged ' .. item.name .. ' - ' ..
                                        self.calculateRanking() .. ' place with ' ..
                                        origin.kills)
                                Timer.after(6, function()
                                    handlers.ui.setMsg('')
                                end)
                            end
                        end
                        -- when dead the flag is left
                        if config.GAME.MATCH_TYPE=='ctf' and item.enemyFlag.status=='taken' then
                            handlers.powerups.unFollowActor(item.enemyFlag)
                            item.enemyFlag.status = 'dropped'
                            if item.team=='blue' then
                                Sound:play("BlueFlagDropped", 'announcer')
                            else
                                Sound:play("RedFlagDropped", 'announcer')
                            end
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

        -- update particle_debris
        for index, impact in ipairs(self.impacts) do
            impact:update(dt)
            if impact:getCount() == 0 then
                table.remove(self.impacts, index)
            end
        end
    end

    function self.draw(self)
        for _i = #self.bullets, 1, -1 do
            local bullet = self.bullets[_i]
            love.graphics.draw(bullet.sprite, math.floor(bullet.x + bullet.w / 2), math.floor(bullet.y + bullet.h / 2), bullet.r, 1, 1, bullet.w / 2, bullet.h / 2)
            -- smoke trails for rockets
            if bullet.of=='Rocket' then
                love.graphics.draw(bullet.pSystem, 0, 0)
            end
        end
        -- drawing particles
        for _i = #self.impacts, 1, -1 do
            local impact = self.impacts[_i]
            love.graphics.draw(impact, 0,0)
        end
    end

    return self

end

return BulletsHandler

