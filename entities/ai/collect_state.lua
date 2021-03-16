local helpers = require "../../helpers.helpers"

local collect = {stateName = 'collect'}

function collect.init(bot)
    -- local current_enemy = helpers.getNearestVisibleEnemy(bot)
    -- local best_waypoint = helpers.getNearestWaypoint(bot)
    -- local best_powerup = helpers.getNearestPowerup(bot)

    if  --[[ current_enemy and (best_powerup.distance<100 or best_waypoint.distance<100) then
        bot.brain.push('collectAndfight')
        return
    elseif ]] current_enemy then
        local enemy = current_enemy.enemy
        if enemy and helpers.isInConeOfView(bot, enemy) then
            bot.target = enemy
            print(bot.name .. ' has ' .. enemy.name .. ' as target')
            bot.brain.push('fight')
            return
        end
    end
    -- bot.nodes = helpers.findPath(bot, best_powerup.item --[[ or best_waypoint ]])
    -- bot.targetItem = best_powerup.item --[[ or best_waypoint ]]
end

function collect.OnEnter(bot)
    print("collect.OnEnter() " .. bot.name)
    -- find best target of movement (collectable or waypoint)
    -- calculate path
    -- if path -> followPath
    collect.init(bot)
end

function collect.OnUpdate(dt, bot)
    -- if there is a target item and a path to this target 
    if next(bot.nodes) == nil then
        -- myTable is empty
        return
    end

    local cell = bot.nodes[0]
    bot.old_x = bot.x
    bot.old_y = bot.y
    -- update bot positions
    local futurex = bot.x
    local futurey = bot.y

    local am = {x = 0, y = 0}
    am.x, am.y = handlers.pf.tileToWorld(cell.x, cell.y)
    -- bot.angleWithTarget = Helper.calculateAngle(bot.x, bot.y, cellx, celly);
    --  We need to get the distance

    local dist, dx, dy = helpers.dist(bot, am)
    if dist ~= 0 then
        futurex = bot.x + dx * bot.speed * dt
        futurey = bot.y + dy * bot.speed * dt
    end
    -- turn to current path node
    helpers.turnProgressivelyTo(bot, am)
    -- collisions
    helpers.checkCollision(bot, futurex, futurey)
    -- if finished move to the next path element
    if dist < 16 then
        bot.path = table.remove(bot.nodes, 1);
        if #bot.nodes == 0 then
            bot.targetItem = {}
            collect.init(bot)
         end
    end
end

function collect.OnLeave(bot)
    print("collect.OnLeave() " .. bot.name)
    -- remove something
end

return collect
