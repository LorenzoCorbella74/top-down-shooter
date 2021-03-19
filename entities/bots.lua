local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory
local FsmMachine = require "entities.ai.fsm"

local BotsHandler = {}

BotsHandler.new = function()

    local self = map:addCustomLayer("bots", 6)

    self.bots = {}

    function self.create(team)

        -- Create player object
        local sprite = Sprites.red_bot
        local bot = {
            index = math.random(1000000), -- id
            name = 'bot' .. #self.bots + 1,
            team = team,
            type = 'actor',
            sprite = sprite,
            x = 0,
            y = 0,
            r = 0,
            velX = 0,
            velY = 0,

            w = sprite:getWidth(),
            h = sprite:getHeight(),
            speed = 256, -- pixels per second

            damage = 1, -- capacity to make damage (1 normal 4 for quad)

            kills = 0, -- enemy killed
            score = 0, -- numero di uccisioni
            numberOfDeaths = 0, -- numero di volte in vui è stato ucciso

            weaponsInventory = WeaponsInventory.new(),

            attackCounter = 0, -- frequenza di sparo

            nodes = {},         -- path to reach an item
            target = {},        -- target for fighting
            best_powerup = {},    -- target of movement
            best_waypoint = {},    -- target of movement

            info = ''           -- for debug
        }
        -- ai
        bot.brain = FsmMachine.new(bot)
        self.spawn(bot)
        table.insert(self.bots, bot)
    end

    function self.spawn(bot)
        bot.x, bot.y, bot.r = handlers.points.getRandomSpawnPoint()
        bot.hp = 100
        bot.ap = 0
        bot.alive = true
        bot.weaponsInventory.resetWeapons()
        world:add(bot, bot.x, bot.y, bot.w, bot.h) -- player bb is in the phisycs world
    end

    function self.die(bot)
        bot.alive = false
        bot.numberOfDeaths = bot.numberOfDeaths + 1
        world:remove(bot) -- removing bot from the phisycs world
        Timer.after(10, function() self.spawn(bot) end)
    end

    function self.fire(p, dt)
        local w = p.weaponsInventory.selectedWeapon
        if p.alive and w.shotNumber > 0 then
            if p.attackCounter > 0 then
                p.attackCounter = p.attackCounter - 1 * dt
            else
                local angle = math.atan2(p.target.y - (p.y + p.h / 2), p.target.x - (p.x + p.w / 2))
                for _i = w.count, 1, -1 do
                    handlers.bullets.create(
                        {
                            x = p.x + (p.w / 2) + 48 * math.cos(angle),
                            y = p.y + (p.h / 2) + 48 * math.sin(angle)
                        }, angle, p)
                end
                p.attackCounter = w.frequency
            end
        else
            p.weaponsInventory.getBest()
        end
    end

    function self.update(self, dt)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]
            if bot.alive then bot.brain.update(dt) end
        end
    end

    function self.draw(self)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]
            if bot.alive then
                love.graphics.draw(bot.sprite, math.floor(bot.x + bot.w / 2), math.floor(bot.y + bot.h / 2), bot.r, 1, 1, bot.w / 2, bot.h / 2)
                -- debug field of view
                if debug then
                    local delta = math.rad(60)
                    local vision_length = 400
                    love.graphics.setColor(0, 0.9, 0, 0.25)
                    love.graphics.arc("fill", bot.x + bot.w / 2, bot.y + bot.h / 2, vision_length, bot.r - delta, bot.r + delta)
                    love.graphics.setColor(0, 0.9, 0, 0.75)
                    love.graphics.arc("line", bot.x + bot.w / 2, bot.y + bot.h / 2, vision_length, bot.r - delta, bot.r + delta)
                    -- coordinates
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(math.floor(bot.x) .. ' ' ..math.floor(bot.y), bot.x, bot.y + 32)
                    love.graphics.print("Angle: " .. tostring(bot.r), bot.x - 16, bot.y + 48)
                    love.graphics.print("State: " .. tostring(bot.brain.curState.stateName), bot.x - 16, bot.y + 70)
                    love.graphics.print("Info: " .. bot.info, bot.x + 70, bot.y + 70)
                end
                -- debug path
                if debug and bot.nodes and #bot.nodes then
                    -- points to cursor
                    for i = 2, #bot.nodes, 1 do
                        local n = bot.nodes[i]
                        local nm = bot.nodes[i - 1]
                        local a = {x = 0, y = 0}
                        local am = {x = 0, y = 0}
                        am.x, am.y = handlers.pf.tileToWorld(nm.x, nm.y)
                        a.x, a.y = handlers.pf.tileToWorld(n.x, n.y)
                        -- linea rossa tiene conto dell'offset al centro del player
                        love.graphics.setColor(1, 0, 0, 1)
                        love.graphics.circle('fill', am.x + 16, am.y + 16, 4)
                        love.graphics.line(am.x + 16, am.y + 16, a.x + 16, a.y + 16)
                        -- linea gialla tiles del path
                        love.graphics.setColor(1, 1, 0, 1)
                        love.graphics.circle('fill', a.x, a.y, 4)
                        love.graphics.line(am.x, am.y, a.x, a.y)
                        love.graphics.rectangle('line', am.x, am.y, 32, 32)
                    end
                end
            end
        end
    end

    return self

end

return BotsHandler

