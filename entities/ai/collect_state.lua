local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)

    -- find best target of movement (collectable or waypoint)
    -- calculate path
    -- if path -> followPath
end

function collect.OnUpdate(dt, bot)

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

function collect.OnLeave(bot)
    print("collect.OnLeave() " .. bot.name)
    -- remove something
end

return collect
