local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.checkIfAChangeStateIsNeeded(bot)
    local enemy = helpers.getNearestVisibleEnemy(bot).enemy
    if enemy then
        if enemy and helpers.isInConeOfView(bot, enemy) and helpers.canBeSeen(bot, enemy) then
            print(bot.name .. ' has ' .. enemy.name .. ' as target')
            bot.target = enemy
            return true
        end
    end
    return false
end

function collect.getTargetOfMovement(bot)
    local start_time = love.timer.getTime()
    bot.best_waypoint = helpers.getRandomtWaypoint(bot)
    bot.best_powerup = helpers.getNearestPowerup(bot)

    -- otherwise collect items
    if  bot.best_powerup.item or bot.best_waypoint.item then
        local best = bot.best_powerup.item or bot.best_waypoint.item
        if best then
            bot.nodes = helpers.findPath(bot, best)
            local end_time = love.timer.getTime()
            local elapsed_time = end_time - start_time
            bot.info = tostring(elapsed_time)
        end
    end
end

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)
    collect.getTargetOfMovement(bot)
end

function collect.OnUpdate(dt, bot)

    -- check if there is a visible enemy
    local needStateChange = collect.checkIfAChangeStateIsNeeded(bot)

    if #bot.nodes== 0 then
        return
    end

    if needStateChange then
        if bot.reactionCounter> 0 then
            bot.reactionCounter = bot.reactionCounter - 1 * dt
        else 
            --sound "found enemy"
            bot.brain.push('fight')
            bot.reactionCounter = bot.parameters.reaction_time -- default
        end
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
    -- if finished move to the next path element
    if dist < 10 then
        table.remove(bot.nodes, 1);
        if #bot.nodes == 0 then
            print('dist '..dist)
            bot.nodes = {}
            bot.best_powerup = helpers.getNearestPowerup(bot)
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
