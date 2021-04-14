local helpers = require "../../helpers.helpers"

local config = require "config"

local fight = {stateName = 'fight', counter = 0}

function fight.OnEnter(bot) print("fight.OnEnter() " .. bot.name) end

function fight.OnUpdate(dt, bot)

     -- check if blocked (during get_last_enemy_position)
     --[[ handlers.timeManagement.runEveryNumFrame(10, bot, function ()
        if bot.x == bot.old_x and bot.y == bot.old_y then
            fight.counter = fight.counter + 1
        end
        if fight.counter == 3 then
            bot.brain.pop()
        end
    end) ]]

     -- check for the nearest enemy
     handlers.timeManagement.runEveryNumFrame(15, bot, function ()
        local enemy = helpers.getNearestVisibleEnemy(bot).enemy
        if enemy then
            if enemy and helpers.isInConeOfView(bot, enemy) and helpers.canBeSeen(bot, enemy) then
                bot.target = enemy
            end
        end
    end)

    local current_enemy = bot.target
    bot.best_powerup = helpers.getObjective(bot)

    bot.old_x = bot.x
    bot.old_y = bot.y

    local futurex = bot.x
    local futurey = bot.y

    if current_enemy and current_enemy.alive and helpers.isInConeOfView(bot, current_enemy) and helpers.canBeSeen(bot, current_enemy) then
        -- setting last visible position
        bot.last_visible_position = {
            x = current_enemy.x + current_enemy.w/2, 
            y = current_enemy.y + current_enemy.h/2
        }
        -- face the target
        helpers.turnProgressivelyTo(bot, current_enemy)

        -- get the team flag if dropped, close and visible
        if config.GAME.MATCH_TYPE=='ctf' and bot.teamFlag and bot.teamFlag.status=='dropped' and helpers.dist(bot, bot.teamFlag) < 250 and helpers.canBeSeen(bot,bot.teamFlag) then
            fight.stateName = 'conquer team flag'
            bot.info = tostring(bot.best_powerup.distance)
            -- get the distance
            local dist, dx, dy = helpers.dist(bot, bot.teamFlag)
            if dist >= 10 then
                futurex = bot.x + (dx / dist) * bot.speed * dt
                futurey = bot.y + (dy / dist) * bot.speed * dt
            end
        -- get the enemy flag if dropped, close and visible
        elseif config.GAME.MATCH_TYPE=='ctf' and bot.enemyFlag and bot.enemyFlag.status=='dropped' and helpers.dist(bot, bot.enemyFlag) < 250 and helpers.canBeSeen(bot,bot.enemyFlag) then
            fight.stateName = 'conquer team flag'
            bot.info = tostring(bot.best_powerup.distance)
            -- get the distance
            local dist, dx, dy = helpers.dist(bot, bot.enemyFlag)
            if dist >= 10 then
                futurex = bot.x + (dx / dist) * bot.speed * dt
                futurey = bot.y + (dy / dist) * bot.speed * dt
            else
                bot.team_role='attack' -- si diventa attaccanti se si prende l'enemy flag
            end
        -- collect close powerup while fighting!!!!!
        elseif bot.best_powerup.item and bot.best_powerup.distance < 250 and helpers.canBeSeen(bot,bot.best_powerup.item) then
            fight.stateName = 'fight_&_collect'
            bot.info = tostring(bot.best_powerup.distance)
            -- get the distance
            local dist, dx, dy = helpers.dist(bot, bot.best_powerup.item)
            if dist >= 10 then
                futurex = bot.x + (dx / dist) * bot.speed * dt
                futurey = bot.y + (dy / dist) * bot.speed * dt
            else
                bot.best_powerup = helpers.getObjective(bot)
            end
        else
            fight.stateName = 'fight'
            local dist, dx, dy = helpers.dist(bot, current_enemy)

            if dist < 250 then
                bot.velX = -dx / dist
                bot.velY = -dy / dist
            elseif dist >= 250 and dist < 350 then
                bot.velX = math.random() < 0.95 and bot.velX or helpers.randomDirection(bot)
                bot.velY = math.random() < 0.95 and bot.velY or helpers.randomDirection(bot)
            elseif dist >= 350  and dist < bot.parameters.view_length then
                -- ci si avvicina solo in base al livello di aggressività e all'attitudine ad auto preserviarsi
                -- if bot.parameters.aggression > bot.parameters.self_preservation then
                    bot.velX = dx / dist
                    bot.velY = dy / dist
            end
            -- update bot positions
            futurex = bot.x + bot.velX * bot.speed * dt;
            futurey = bot.y + bot.velY * bot.speed * dt;
        end

        -- check collision
        helpers.checkCollision(bot, futurex, futurey)

        -- fire - > according to a bot characteristics
        if bot.reactionCounter> 0 then
            bot.reactionCounter = bot.reactionCounter - 1 * dt
        else 
            bot.canFire = true
        end
        if bot.canFire then
            handlers.bots.fire(bot, dt)
        end

    -- if enemy is no more visible go to last enemy position
    elseif bot.last_visible_position and not helpers.canBeSeen(bot, current_enemy) and bot.parameters.aggression > bot.parameters.self_preservation then
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
        bot.brain.pop()
        return
    end

end

function fight.OnLeave(bot) 
    print("fight.OnLeave() " .. bot.name)
    bot.target = nil
    bot.last_visible_position = nil
    bot.underAttack = false -- set default
    bot.reactionCounter = bot.parameters.reaction_time -- set default
    bot.canFire = false
    fight.counter = 0
end

return fight
