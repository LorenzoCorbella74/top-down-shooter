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
            w = sprite:getWidth(),
            h = sprite:getHeight(),
            speed = 256, -- pixels per second

            damage = 1, -- capacity to make damage (1 normal 4 for quad)

            kills = 0, -- enemy killed
            score = 0, -- numero di uccisioni
            numberOfDeaths = 0, -- numero di volte in vui è stato ucciso

            weaponsInventory = WeaponsInventory.new(),

            attackCounter = 0, -- frequenza di sparo

            path = {},          -- path to reach an item
            target = {},        -- target for fighting
            targetItem = {}     -- target of movement
        }
        -- ai
        bot.brain = FsmMachine.new(bot)
        bot.brain.init() -- wamder as default

        table.insert(self.bots, bot)
        self.spawn(bot)
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
                end
            end
        end
    end

    return self

end

return BotsHandler

