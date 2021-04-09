local helpers = require "../../helpers.helpers"

local collectctf = {stateName = 'collectctf'}

function collectctf.OnEnter(bot)
    print("collectctf.OnEnter() " .. bot.name)
    collectctf.getTargetOfMovementAndPath(bot)
end

function collectctf.OnUpdate(dt, bot)

    local needStateChange = nil
    -- check if there is a visible enemy 4 times/sec
    handlers.timeManagement.runEveryNumFrame(15, function()
        needStateChange = collectctf.checkIfThereIsEnemy(bot)
    end)
    if needStateChange then
        bot.brain.push('fight')
        return
    end

    if #bot.nodes == 0 then return end

    -- if underAttack turn to the point of impact of the received bullet
    if bot.underAttack then
        helpers.turnProgressivelyTo(bot, bot.underAttackPoint)
        return
    end

    -- if item is not visible and can be seen check another item
    if bot.best_powerup.item and bot.best_powerup.item.visible == false and helpers.canBeSeen(bot, bot.best_powerup.item) then
        handlers.powerups.trackBot(bot.best_powerup.item.id, bot) -- powerup is tracked as it was touch!
        bot.nodes = {}
        collectctf.getTargetOfMovementAndPath(bot)
        return
    end

    -- follow the path and when finished run the callback
    helpers.followPath(bot, dt, function()
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
    local opposite_team = bot.team == 'team1' and 'team2' or 'team1'
    bot.teamFlag = bot.teamStatus[opposite_team].enemyFlag
    bot.enemyFlag = bot.teamStatus[bot.team].enemyFlag
    bot.best_waypoint = helpers.getRandomtWaypoint(bot)
    bot.best_powerup = helpers.getObjective(bot)
    bot.best = bot.best_powerup.distance < bot.best_waypoint.distance and bot.best_powerup.item or bot.best_waypoint.item

    -- choose objective according to team role

    -- get the enemy flag if you have the role
    if bot.teamStatus[bot.team].enemyFlagStatus == 'base' and bot.team_role == 'attack' then 
        bot.nodes = helpers.findPath(bot, bot.enemyFlag)
    elseif bot.teamStatus[bot.team].enemyFlagStatus == 'taken' and bot.teamStatus[bot.team].carrier == bot then
        -- after taking the enemy flag come back to the teamFlag position
        local origin = {x = bot.teamFlag.originx, y= bot.teamFlag.originy}
        bot.nodes = helpers.findPath(bot, origin)
    elseif bot.teamStatus[opposite_team].enemyFlagStatus == 'taken' and bot.teamStatus[bot.team].carrier == bot then
        -- if team flag has been taken go to powerups
        bot.nodes = helpers.findPath(bot, bot.best)
    elseif bot.teamStatus[opposite_team].enemyFlagStatus == 'base' and bot.teamStatus[bot.team].carrier == bot then
        -- if team flag has returned
        bot.nodes = helpers.findPath(bot, bot.teamFlag)
    elseif bot.teamStatus[bot.team].enemyFlagStatus == 'dropped' and helpers.canBeSeen(bot, bot.enemyFlag) then
        -- if enemy flag was dropp take it
        bot.nodes = helpers.findPath(bot, bot.enemyFlag)
    elseif bot.teamStatus[opposite_team].enemyFlagStatus == 'dropped' and helpers.canBeSeen(bot, bot.teamFlag) then
        -- if team flag was dropped take it to return it
        bot.nodes = helpers.findPath(bot, bot.teamFlag)
    elseif bot.team_role == 'defend' then
        -- TODO: waypoint di tipo "defense"
        bot.nodes = helpers.findPath(bot, bot.best) 
    elseif bot.team_role == 'support' then
        -- TODO: support team mates
        bot.nodes = helpers.findPath(bot, bot.best)
    else
        --default
        bot.nodes = helpers.findPath(bot, bot.best)
    end
    local end_time = love.timer.getTime()
    local elapsed_time = end_time - start_time
    bot.info = tostring(elapsed_time)
end

function collectctf.OnLeave(bot)
    print("collectctf.OnLeave() " .. bot.name)
    -- remove something
end

return collectctf
