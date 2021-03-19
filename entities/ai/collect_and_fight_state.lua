local helpers = require "../../helpers.helpers"

local collectAndfight = {stateName = 'collectAndfight'}

function collectAndfight.OnEnter(bot)
    print("collectAndfight.OnEnter() " .. bot.name)
    -- find best target of movement (collectAndfightable or waypoint)
    -- calculate path
end

function collectAndfight.OnUpdate(dt, bot)

    local current_enemy = bot.target
    local current_powerup = bot.best_powerup.item
    if current_enemy and current_enemy.alive and
        helpers.isInConeOfView(bot, current_enemy) and
        helpers.canBeSeen(bot, current_enemy) and current_powerup then

        bot.old_x = bot.x
        bot.old_y = bot.y

        local futurex = bot.x
        local futurey = bot.y

        -- get the distance
        local dist, dx, dy = helpers.dist(bot, current_powerup)
        if dist ~= 0 then
            futurex = bot.x + (dx / dist) * bot.speed * dt
            futurey = bot.y + (dy / dist) * bot.speed * dt
        end
        -- collisions
        helpers.checkCollision(bot, futurex, futurey)
        
        -- face the target
        helpers.turnProgressivelyTo(bot, current_enemy)
        -- fire
        -- handlers.bots.fire(bot, dt)

        -- if finished move to the next path element
        if dist < 10 then 
            bot.best_powerup = {}
            -- bot.brain.pop()
        end
    elseif not current_powerup then
        bot.brain.push('fight')
    else
        bot.target = {}
        bot.brain.pop()
        return
    end

end

function collectAndfight.OnLeave(bot)
    print("collectAndfight.OnLeave() " .. bot.name)
    -- remove something
end

return collectAndfight
