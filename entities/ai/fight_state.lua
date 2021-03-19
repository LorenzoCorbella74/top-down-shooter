local helpers = require "../../helpers.helpers"

local fight = {stateName = 'fight'}

function fight.OnEnter(bot) print("fight.OnEnter() " .. bot.name) end

function fight.OnUpdate(dt, bot)

    local current_enemy = bot.target

    local lastVisibleposition = {
        x = current_enemy.x,
        y = current_enemy.y,
    }

    if current_enemy and current_enemy.alive and
        helpers.isInConeOfView(bot, current_enemy) and
        helpers.canBeSeen(bot, current_enemy) then

        -- face the target
        helpers.turnProgressivelyTo(bot, current_enemy)

        bot.old_x = bot.x
        bot.old_y = bot.y

        local futurex = bot.x
        local futurey = bot.y
    
        
        local dist, dx, dy = helpers.dist(bot, current_enemy)
        
        if dist < 250 then
            bot.velX = -dx / dist
            bot.velY = -dy / dist
        elseif dist >= 250 and dist < 350 then
            bot.velX = math.random() < 0.95 and bot.velX or helpers.randomDirection(bot)
            bot.velY = math.random() < 0.95 and bot.velY or helpers.randomDirection(bot)
        elseif dist >= 350 then
            bot.velX = dx / dist
            bot.velY = dy / dist
        end
        -- update bot positions
        futurex = bot.x + bot.velX * bot.speed * dt;
        futurey = bot.y + bot.velY * bot.speed * dt;
        -- check collision
        helpers.checkCollision(bot, futurex, futurey)
        -- fire
        handlers.bots.fire(bot, dt)
    else
        bot.target = {}
        bot.brain.pop()
        return
    end

end

function fight.OnLeave(bot) print("fight.OnLeave() " .. bot.name) end

return fight
