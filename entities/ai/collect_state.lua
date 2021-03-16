local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)
    -- find best target of movement (collectable or waypoint)
    -- calculate path
    -- if path -> followPath
end

function collect.OnUpdate(dt, bot)

    local current_enemy = helpers.getNearestVisibleEnemy(bot)
    if current_enemy then
        local enemy = current_enemy.enemy
        if enemy and helpers.isInConeOfView(bot, enemy) then
            bot.target = enemy
            print(bot.name .. ' has ' .. enemy.name .. ' as target')
            bot.brain.push('fight')
            return
        end
    end

    bot.old_x = bot.x
    bot.old_y = bot.y

    -- update bot positions
    local futurex = bot.x
    local futurey = bot.y

    -- collisions
    helpers.checkCollision(bot,futurex, futurey)
end

function collect.OnLeave(bot)
    print("collect.OnLeave() " .. bot.name)
    -- remove something
end

return collect
