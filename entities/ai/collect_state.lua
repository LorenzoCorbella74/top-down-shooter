local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.checkIfAChangeStateIsNeeded(bot)
    local enemy = helpers.getNearestVisibleEnemy(bot).enemy
    if enemy then
        print(bot.name .. ' has ' .. enemy.name .. ' as target')
        bot.target = enemy
        return true
    end
    return false
end

function collect.getTargetOfMovement(bot)
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

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)
    collect.getTargetOfMovement(bot)
end

function collect.OnUpdate(dt, bot)
    
    local needStateChange = nil

    -- check if there is a visible enemy
    handlers.timeManagement.runEveryNumFrame(5, function ()
        needStateChange = collect.checkIfAChangeStateIsNeeded(bot)
    end)
    
    if #bot.nodes== 0 then
        return
    end
    
    if needStateChange then
        bot.brain.push('fight')
        return
    end

    -- if underAttack turn to the point of impact of the received bullet
    if bot.underAttack then
        local  contact_point = bot.underAttackPoint
        helpers.turnProgressivelyTo(bot, contact_point)
        return
    end

    -- if there is a target item and a path to this target
    local cell = bot.nodes[1]
    bot.old_x = bot.x
    bot.old_y = bot.y
    -- update bot positions
    local futurex = bot.x
    local futurey = bot.y

    local am = {x = 0, y = 0}
    am.x, am.y = handlers.pf.tileToWorld(cell.x, cell.y)

    -- get the distance
    local dist, dx, dy = helpers.dist(bot, am)
    if dist ~= 0 then
        futurex = bot.x + (dx / dist) * bot.speed * dt
        futurey = bot.y + (dy / dist) * bot.speed * dt
    end
    -- turn to current path node
    helpers.turnProgressivelyTo(bot, am)
    -- collisions
    helpers.checkCollision(bot, futurex, futurey)

    -- if item is not visible and can be seen check another item
    if bot.best_powerup.item and bot.best_powerup.item.visible == false and helpers.canBeSeen(bot,bot.best_powerup.item) then
        handlers.powerups.trackBot(bot.best_powerup.item.id, bot) -- powerup is tracked as it was touch!
        bot.nodes = {}
        collect.getTargetOfMovement(bot)
        return
    end

    -- if finished move to the next path element
    if dist < 10 then
        table.remove(bot.nodes, 1);
        if #bot.nodes == 0 then
            print('dist '..dist)
            bot.nodes = {}
            bot.best_powerup = helpers.getObjective(bot)
            -- block when distance is reduced fast (when speed powerup is staken) or no item are found
            if dist > 2 then
                collect.getTargetOfMovement(bot)
            else
                print('Bot is blocked...')
                -- if no powerup go with the waypoint
                bot.nodes = helpers.findPath(bot, bot.best_waypoint.item)
            end
        end
    end
end

function collect.OnLeave(bot)
    print("collect.OnLeave() " .. bot.name)
    -- remove something
end

return collect
