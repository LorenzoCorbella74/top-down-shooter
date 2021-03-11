local helpers = require "../../helpers.helpers"

local collectAndfight = {stateName = 'collectAndfight'}

function collectAndfight.OnEnter(bot)
    print("collectAndfight.OnEnter() " .. bot.name)
    -- find best target of movement (collectAndfightable or waypoint)
    -- calculate path
end

function collectAndfight.OnUpdate(dt, bot)

    -- if #path -> followPath (dt)
    
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

    -- collisions
    local cols, cols_len
    bot.x, bot.y, cols, cols_len = world:move(bot, futurex, futurey)
end

function collectAndfight.OnLeave(bot)
    print("collectAndfight.OnLeave() " .. bot.name)
    -- remove something
end

return collectAndfight
