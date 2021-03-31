local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory
local FsmMachine = require "entities.ai.fsm"
local config = require "config"

local helpers = require "../helpers.helpers"

local BotsHandler = {}

BotsHandler.new = function()

    local self = map:addCustomLayer("bots", 6)

    self.bots = {}

    function self.createPersonality(level)          -- 0 to 5
        return {    
                aggression = 0.8,                   -- attitudine ad attaccare un nemico       -> "quanto" sceglierà l'attacco
                fire_throttle = 0.8,                -- tendenza a non interrompere il firing   -> quanto sceglierà se continuare a sparare anche senza target (uso munizioni)
                self_preservation = 7,              -- attitudine ad auto preserviarsi         -> "quanto" sceglierà di ripiegare
                alertness = 7,                      -- attitudine ad essere vigile ???
                camp = 1,                           -- attitudine a stare fermo

                view_length = 300 + 40 * level,     -- capacità di visione
                view_angle = 40 + 4*(level),        -- angolo di visione in gradi (sx <- direzione -> dx)

                reaction_time = 0.35,               -- tempo di reazione (ms) a seguito di visione
                aim_prediction_skill = 0.2*level,   -- capacità di mirare (predirre la posizione del target)
                aim_accuracy = 4,                   -- accuratezza del mirare () ampiezza scostamento dal target
        }
    end

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

            attackCounter = 0,    -- frequenza di sparo
            reactionCounter = 1,  -- tempo di reazione una volta avvistato un nemico

            nodes = {},           -- path to reach an item
            target = {},          -- target for fighting
            best_powerup = {},    -- target of movement
            best_waypoint = {},   -- target of movement
            underAttack = false,  -- if underAttack turn to the bullet_collision_point

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
                -- bullet prediction -> how well bots are aiming!!
                local predvX = (p.target.x - p.target.old_x) / (p.target.speed * dt) / (p.speed * dt);
                local predvY = (p.target.y - p.target.old_y) / (p.target.speed * dt) / (p.speed * dt);
                -- print('Prediction :', tostring(predvX),tostring(predvY)) -- dell'ordine di +/- 0.25

                -- bot skill level
                predvX = math.random() < config.GAME.BOTS_PREDICTION_SKILL and predvX or 0
                predvY = math.random() < config.GAME.BOTS_PREDICTION_SKILL and predvY or 0

                local dist, dx, dy = helpers.dist(p, p.target)
                local velX = dx / dist + predvX
                local velY = dy / dist + predvY
                -- angle with target
                local angle = math.atan2(velY, velX)

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
                    local delta = math.rad(config.GAME.BOTS_VISION_ANGLE)
                    local vision_length = config.GAME.BOTS_VISION_LENGTH
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

