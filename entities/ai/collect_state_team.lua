local helpers = require "../../helpers.helpers"

local collectTeam = {stateName = 'collectTeam'}

function collectTeam.OnEnter(bot)
    print("collectTeam.OnEnter() " .. bot.name)
    collectTeam.getTargetOfMovementAndPath(bot)
end

function collectTeam.OnUpdate(dt, bot)

    local holyShit = nil
    -- check if there is a visible enemy 4 times/sec
    handlers.timeManagement.runEveryNumFrame(20, bot, function ()
        holyShit = helpers.checkIfThereIsEnemy(bot)
    end)
    if holyShit then
        bot.brain.push('fight')
        return
    end

     -- if underAttack turn to the point of impact of the received bullet
     if bot.underAttack then
        local angle = helpers.turnProgressivelyTo(bot, bot.underAttackPoint)
        if --[[ bot.target == nil and ]] math.abs(angle) <0.05 then -- circa 3°
            bot.underAttack = false
        else
            return
        end
    end

    -- check if there is a visible mate (which is fighting) and support him!
     handlers.timeManagement.runEveryNumFrame(30, bot, function ()
        local actor = helpers.getNearestFightingMate(bot)
        if actor and actor.mate and not bot.isSupporting then
            bot.nodes = helpers.findPath(bot, actor.mate)
            collectTeam.stateName = 'support'
            bot.isSupporting = true
        end
    end)

    if #bot.nodes== 0 then
        return
    end

    -- if item is not visible and can be seen check another item
    if bot.best_powerup.item and bot.best_powerup.item.visible == false and helpers.canBeSeen(bot,bot.best_powerup.item) then
        handlers.powerups.trackBot(bot.best_powerup.item.id, bot) -- powerup is tracked as it was touch!
        bot.nodes = {}
        collectTeam.getTargetOfMovementAndPath(bot)
        return
    end

    -- follow the path and when finished run the callback
    helpers.followPath (bot, dt, function ()
        if bot.isSupporting == true then
            bot.isSupporting = false
        end
        collectTeam.stateName = 'collectTeam'
        collectTeam.getTargetOfMovementAndPath(bot)
    end)
end

-- return the best item and the path to reach it
function collectTeam.getTargetOfMovementAndPath(bot)
    local start_time = love.timer.getTime()
    bot.best_waypoint = helpers.getRandomtWaypoint(bot)
    bot.best_powerup = helpers.getObjective(bot)
    bot.best = bot.best_powerup.distance < bot.best_waypoint.distance and bot.best_powerup.item or bot.best_waypoint.item
    bot.nodes = helpers.findPath(bot, bot.best)
    local end_time = love.timer.getTime()
    local elapsed_time = end_time - start_time
    bot.info = tostring(math.floor(elapsed_time))
end

function collectTeam.OnLeave(bot)
    print("collectTeam.OnLeave() " .. bot.name)
    -- remove something
    bot.isSupporting = false
end

return collectTeam
