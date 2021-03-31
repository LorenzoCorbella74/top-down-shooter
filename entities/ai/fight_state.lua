local helpers = require "../../helpers.helpers"

local fight = {stateName = 'fight'}

function fight.OnEnter(bot) print("fight.OnEnter() " .. bot.name) end

function fight.OnUpdate(dt, bot)

    local current_enemy = bot.target
    bot.best_powerup = helpers.getNearestPowerup(bot)

    bot.old_x = bot.x
    bot.old_y = bot.y

    local futurex = bot.x
    local futurey = bot.y

    if current_enemy and current_enemy.alive and helpers.isInConeOfView(bot, current_enemy) and helpers.canBeSeen(bot, current_enemy) then
        -- setting last visible position
        bot.last_visible_position = {x = current_enemy.x, y = current_enemy.y}
        -- face the target
        helpers.turnProgressivelyTo(bot, current_enemy)

        -- collect close powerup while fighting!!!!!
        if bot.best_powerup.item and bot.best_powerup.distance < 250 then
            fight.stateName = 'fight_&_collect'
            bot.info = tostring(bot.best_powerup.distance)
            -- get the distance
            local dist, dx, dy = helpers.dist(bot, bot.best_powerup.item)
            if dist >= 10 then
                futurex = bot.x + (dx / dist) * bot.speed * dt
                futurey = bot.y + (dy / dist) * bot.speed * dt
            else
                bot.best_powerup = helpers.getNearestPowerup(bot)
            end
        else
            fight.stateName = 'fight'
            local dist, dx, dy = helpers.dist(bot, current_enemy)

            if dist < 250 then
                bot.velX = -dx / dist
                bot.velY = -dy / dist
            elseif dist >= 250 and dist < 375 then
                bot.velX = math.random() < 0.95 and bot.velX or helpers.randomDirection(bot)
                bot.velY = math.random() < 0.95 and bot.velY or helpers.randomDirection(bot)
            elseif dist >= 375 then
                -- ci si avvicina solo in base al livello di aggressività e all'attitudine ad auto preserviarsi
                if bot.parameters.aggression > bot.parameters.self_preservation then
                    bot.velX = dx / dist
                    bot.velY = dy / dist
                else
                    bot.velX = -dx / dist
                    bot.velY = -dy / dist
                end
            end
            -- update bot positions
            futurex = bot.x + bot.velX * bot.speed * dt;
            futurey = bot.y + bot.velY * bot.speed * dt;
        end

        -- check collision
        helpers.checkCollision(bot, futurex, futurey)
        -- fire - > according to a bot characteristics
        handlers.bots.fire(bot, dt)
        -- if enemy is no more visible go to last enemy position
    elseif bot.last_visible_position then
        bot.underAttack = false -- bot is fighting and is no more surprised of a received bullet
        fight.stateName = 'get_last_enemy_position'
        local dist, dx, dy = helpers.dist(bot, bot.last_visible_position)
        if dist >= 12 then
            futurex = bot.x + (dx / dist) * bot.speed * dt
            futurey = bot.y + (dy / dist) * bot.speed * dt
            -- check collision
            helpers.checkCollision(bot, futurex, futurey)
        else
            bot.last_visible_position = nil
        end
    else
        bot.last_visible_position = nil
        bot.underAttack = false -- set default
        bot.target = {}
        bot.brain.pop()
        return
    end

end

function fight.OnLeave(bot) print("fight.OnLeave() " .. bot.name) end

return fight
