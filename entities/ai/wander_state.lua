local helpers = require "../../helpers.helpers"

local wander = {
    stateName = 'wander'
}

function wander.OnEnter(bot) print("wander.OnEnter() " .. bot.name) end

function wander.OnUpdate(dt, bot)

    if bot.alive then

        local canBeSeen = helpers.canBeSeen(bot, handlers.player.player)
        -- print('canBeSeen '..tostring(canBeSeen))

        if helpers.isInConeOfView(bot, handlers.player.player) and canBeSeen then 
            helpers.turnProgressivelyTo(bot, handlers.player.player)
        end

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

function wander.OnLeave(bot) print("wander.OnLeave() " .. bot.name) end

return wander
