local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)
    collect.getTargetOfMovementAndPath(bot)
end

function collect.OnUpdate(dt, bot)

    local needStateChange = nil
    -- check if there is a visible enemy 4 times/sec
    handlers.timeManagement.runEveryNumFrame(15, function ()
        needStateChange = collect.checkIfThereIsEnemy(bot)
    end)
    if needStateChange then
        bot.brain.push('fight')
        return
    end

    if #bot.nodes== 0 then
        return
    end

    -- if underAttack turn to the point of impact of the received bullet
    if bot.underAttack then
        helpers.turnProgressivelyTo(bot, bot.underAttackPoint)
        return
    end

    -- if item is not visible and can be seen check another item
    if bot.best_powerup.item and bot.best_powerup.item.visible == false and helpers.canBeSeen(bot,bot.best_powerup.item) then
        handlers.powerups.trackBot(bot.best_powerup.item.id, bot) -- powerup is tracked as it was touch!
        bot.nodes = {}
        collect.getTargetOfMovementAndPath(bot)
        return
    end

    -- follow the path and when finished run the callback
    helpers.followPath(bot, dt, function ()
        collect.getTargetOfMovementAndPath(bot)
    end)
end

function collect.checkIfThereIsEnemy(bot)
    local enemy = helpers.getNearestVisibleEnemy(bot).enemy
    if enemy then
        print(bot.name .. ' has ' .. enemy.name .. ' as target')
        bot.target = enemy
        return true
    end
    return false
end

-- return the best item and the path to reach it
function collect.getTargetOfMovementAndPath(bot)
    local start_time = love.timer.getTime()
    bot.best_waypoint = helpers.getRandomtWaypoint(bot)
    bot.best_powerup = helpers.getObjective(bot)
    if  bot.best_powerup.item or bot.best_waypoint.item then
        bot.best = bot.best_powerup.distance < bot.best_waypoint.distance and bot.best_powerup.item or bot.best_waypoint.item
        -- if best then
            bot.nodes = helpers.findPath(bot, bot.best)
            local end_time = love.timer.getTime()
            local elapsed_time = end_time - start_time
            bot.info = tostring(elapsed_time)
        -- end
    else
        bot.best = nil
    end
end

function collect.OnLeave(bot)
    print("collect.OnLeave() " .. bot.name)
    -- remove something
end

return collect
