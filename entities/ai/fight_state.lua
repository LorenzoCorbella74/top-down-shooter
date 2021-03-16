local helpers = require "../../helpers.helpers"

local fight = {stateName = 'fight'}

function fight.OnEnter(bot) print("fight.OnEnter() " .. bot.name) end

function fight.OnUpdate(dt, bot)

    local current_enemy = bot.target

    local lastVisibleposition = {}

    if helpers.isInConeOfView(bot, current_enemy) and
        helpers.canBeSeen(bot, current_enemy) then
        helpers.turnProgressivelyTo(bot, current_enemy)

        bot.old_x = bot.x
        bot.old_y = bot.y

        -- update bot positions
        local futurex = bot.x
        local futurey = bot.y

        -- collisions
        local cols, cols_len

        helpers.checkCollision(bot,futurex, futurey)
    else
        bot.target = {}
        bot.brain.pop()
        return
    end

end

function fight.OnLeave(bot) print("fight.OnLeave() " .. bot.name) end

return fight
