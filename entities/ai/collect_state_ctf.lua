local helpers = require "../../helpers.helpers"

local collectctf = {stateName = 'collectctf'}

function collectctf.OnEnter(bot)
    print("collectctf.OnEnter() " .. bot.name)
    local opposite_team = bot.team == 'blue' and 'red' or 'blue'
    -- flags
    bot.teamFlag = handlers.powerups.flags[bot.team]
    bot.enemyFlag = handlers.powerups.flags[opposite_team]
    collectctf.getTargetOfMovementAndPath(bot)
end

function collectctf.OnUpdate(dt, bot)

    if bot.team_role == 'defend' and bot.objective =='look-at-target' then
        local angle = helpers.turnProgressivelyTo(bot,nil, math.rad(bot.defend_point.angle))
        if math.abs(angle) <0.05 then -- circa 3°
            bot.objective ='in-position'
            print('in-position')
        end
    end

    local needStateChange = nil
    -- check if there is a visible enemy 4 times/sec
    handlers.timeManagement.runEveryNumFrame(15, function()
        needStateChange = collectctf.checkIfThereIsEnemy(bot)
    end)
    if needStateChange then
        bot.brain.push('fight')
        return
    end

    -- check if there is a visible short term goal 3 times/sec on the path for long term goal
    handlers.timeManagement.runEveryNumFrame(15, function()
         if bot.team_role == 'attack' and not bot.hasShortTermObjective then
            bot.best_powerup = helpers.getShortTermObjective(bot, 350)
            if bot.best_powerup then
                print('Score: '..tostring(bot.best_powerup.item.id)..' - '..tostring(bot.best_powerup.score)..' - '..tostring(bot.best_powerup.desiderability))
                if bot.best_powerup and bot.best_powerup.score > 0.0001 then
                    bot.nodes = helpers.findPath(bot, bot.best_powerup.item)
                    bot.hasShortTermObjective = true
                    return
                else
                    bot.hasShortTermObjective = false
                end
            end
        end
    end)

    if #bot.nodes == 0 then
        return 
    end

     -- if underAttack turn to the point of impact of the received bullet
    if bot.underAttack then
        local angle = helpers.turnProgressivelyTo(bot, bot.underAttackPoint)
        if bot.target == nil and angle <0.05 then -- circa 3°
            bot.underAttack = false
        else
            return
        end
    end

    -- if item is not visible and can be seen check another item
    if bot.best_powerup and bot.best_powerup.item and bot.best_powerup.item.visible == false and helpers.canBeSeen(bot, bot.best_powerup.item) then
        handlers.powerups.trackBot(bot.best_powerup.item.id, bot) -- powerup is tracked as it was touch!
        bot.nodes = {}
        collectctf.getTargetOfMovementAndPath(bot)
        return
    end

    -- follow the path and when finished run the callback
    helpers.followPath(bot, dt, function()
        if bot.hasShortTermObjective then
            bot.hasShortTermObjective = false
        end
        if bot.team_role=='defend' and bot.objective =='defence-position'then
                bot.objective ='look-at-target'
        end
        collectctf.getTargetOfMovementAndPath(bot)
    end)
end

function collectctf.checkIfThereIsEnemy(bot)
    local enemy = helpers.getNearestVisibleEnemy(bot).enemy
    if enemy then
        print(bot.name .. ' has ' .. enemy.name .. ' as target')
        bot.target = enemy
        return true
    end
    return false
end

-- return the best item and the path to reach it
function collectctf.getTargetOfMovementAndPath(bot)
    local start_time = love.timer.getTime()

    -- powerups and waypoints
    bot.best_waypoint = helpers.getRandomtWaypoint(bot)
    bot.best_powerup = helpers.getObjective(bot)
    bot.best = bot.best_powerup.distance < bot.best_waypoint.distance and bot.best_powerup.item or bot.best_waypoint.item

    -- choose objective according to team role --

    if bot.team_role == 'attack' then
        -- enemy flag
        if bot.enemyFlag.status == 'base' then 
            -- get the enemy flag if you have the role attack
            bot.nodes = helpers.findPath(bot, bot.enemyFlag)
        elseif  bot.enemyFlag.status == 'taken' and bot.enemyFlag.attachedTo == bot then
            -- after taking the enemy flag come back to the teamFlag position
            local origin = {x = bot.teamFlag.originx, y= bot.teamFlag.originy}
            bot.nodes = helpers.findPath(bot, origin)
        elseif bot.enemyFlag.status == 'dropped' and helpers.canBeSeen(bot, bot.enemyFlag) then
            -- if enemy flag was dropped and is visible take it
            bot.nodes = helpers.findPath(bot, bot.enemyFlag)
        end
        return
    end
    
    --team flag (tutti i ruoli)
    if bot.teamFlag.status == 'taken' and bot.enemyFlag.attachedTo == bot then
        -- if team flag has been taken and bot has enemyFlag go to powerups 
        bot.nodes = helpers.findPath(bot, bot.best)
        return
    elseif bot.teamFlag.status == 'base' and bot.enemyFlag.attachedTo == bot then
        -- if team flag has returned and bot has enemy flag
        bot.nodes = helpers.findPath(bot, bot.teamFlag)
        return
    elseif bot.teamFlag.status == 'dropped' and helpers.canBeSeen(bot, bot.teamFlag) then
        -- if team flag was dropped take it to return it
        bot.nodes = helpers.findPath(bot, bot.teamFlag)
        return
    end
    
    if bot.team_role == 'defend' and bot.objective == nil then
        -- il bot deciderà se andare a difendere quando la bandiera è alla base (e a seconda di dove nasce cercherà
        -- dei short term goal sul percorso del long term goal)- altrimenti avrà un comportamento libero
        if bot.teamFlag.status == 'base' then
            -- waypoint di tipo "defence"
            bot.defend_point = helpers.getDefendPoint(bot, bot.teamFlag)
            if bot.defend_point ~= nil then
                bot.nodes = helpers.findPath(bot, bot.defend_point)
                bot.objective ='defence-position'
                print('defence-position')
            else
                bot.nodes = helpers.findPath(bot, bot.best)
            end
        else
            bot.nodes = helpers.findPath(bot, bot.best)
        end
    end
    
    if bot.team_role == 'support' then
        -- se vede un compagno sotto attacco lo seguirà o con la bandiera nemica 
        -- o se la bandiera del team non è più alla base
        -- altrimenti avrà un comportamento libero
        bot.nodes = helpers.findPath(bot, bot.best)
    end

    local end_time = love.timer.getTime()
    local elapsed_time = end_time - start_time
    bot.info = tostring(elapsed_time)
end

function collectctf.OnLeave(bot)
    print("collectctf.OnLeave() " .. bot.name)
    bot.objective = nil
    -- remove something
end

return collectctf
