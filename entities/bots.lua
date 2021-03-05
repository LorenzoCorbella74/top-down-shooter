local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory

local BotsHandler = {}

BotsHandler.new = function()

    local self = map:addCustomLayer("bots", 6)

    self.bots = {}

    --[[ local filter = function (item, other)
        local kind = other.layer and other.layer.name or other
        -- print(('Kind:%s'):format(kind))
        if kind == 'walls' then
            return "bounce"
        else
            return nil
        end
    end ]]

    function self.create()
        
            -- Create player object
            local sprite = Sprites.red_bot
            local bot = {
                index = math.random(1000000), -- id
                name = 'bot'..#self.bots+1,
                team = 'red',
                type= 'actor',
                sprite = sprite,
                w = sprite:getWidth(),
                h = sprite:getHeight(),
                speed = 256, -- pixels per second
    
                damage = 1, -- capacity to make damage (1 normal 4 for quad)
    
                kills = 0, -- enemy killed
                score = 0, -- numero di uccisioni
                numberOfDeaths = 0, -- numero di volte in vui è stato ucciso
    
                weaponsInventory = WeaponsInventory.new(),
    
                path = {},
                nodes = {}
            }
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
        world:remove(bot) -- removing bot from the phisycs world
        bot.numberOfDeaths = bot.numberOfDeaths + 1
        -- aumenta score di chi ha ucciso il bot
        Timer(10, function()
            self.spawn(bot)
        end)
    end

    function self.update(self, dt)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]

            bot.old_x = bot.x
            bot.old_y = bot.y

            -- update bot positions
            local futurex = bot.x
            local futurey = bot.y

            local cols, cols_len

            bot.x, bot.y, cols, cols_len = world:move(bot, futurex, futurey)

            -- collisions

            -- ai logics
        end
    end

    function self.draw(self)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]
            love.graphics.draw(bot.sprite, math.floor(bot.x + bot.w / 2), math.floor(bot.y + bot.h / 2), bot.r, 1, 1, bot.w / 2, bot.h / 2)
        end
        -- debug
        if debug then
        end
    end

    return self

end

return BotsHandler

