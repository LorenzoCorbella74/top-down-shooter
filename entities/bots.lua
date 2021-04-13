local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory
local FsmMachine = require "entities.ai.fsm"
local config = require "config"

local helpers = require "../helpers.helpers"
local teams = require "../helpers.teams"        -- simple shared table

local BotsHandler = {}

BotsHandler.new = function()

    local self = map:addCustomLayer("bots", 6)

    self.bots = {}

    function self.defineTeams (index)
        if config.GAME.MATCH_TYPE == 'deathmatch' then -- tutti i bot hanno un team diverso...
            return 'team' .. index + 1 -- player is always "blue"
        else -- per teamDeathMatch e CTF
            if index < math.floor(config.GAME.BOTS_NUMBERS / 2)+1 then
                return 'blue'
            else
                return 'red'
            end
        end
    end

    -- in futuro sarà una tabella con tutti i nomi dei bot e relative preferenze di armi
    function self.createWeaponPreferences()
        return {
                Rifle= 0.5,
                Shotgun= 0.9,
                Rocket= 0.6,
                Plasma= 0.7,
                Railgun= 1
            }
    end

    --  per team play (una sola tra le prox tre): in futuro sarà impostato in fase di creazione in funz del game_type
    function self.createRole(num)
        local role = {
            'defend',   -- attitudice a difendere un obittivo   (difensore)
            'attack',   -- attitudine ad attaccare un obiettivo (attaccante)
            'support'   -- attitudine al supporto compagni      (supporto)
        }
        return role[num]
    end

    function self.createPersonality(level) -- 0 to 5
        return {
            aggression = math.random(0.5, 1),           -- attitudine ad attaccare un nemico       -> "quanto" sceglierà l'attacco
            self_preservation = math.random(0.5, 1),    -- attitudine ad auto preserviarsi         -> "quanto" sceglierà di ripiegare
            fire_throttle = 0.5,                        -- tendenza a non interrompere il firing   -> quanto sceglierà se continuare a sparare anche senza target (uso munizioni)
            -- camp = 1,                                -- attitudine a stare fermo

            view_length = 400 + 40 * level,             -- capacità di visione
            view_angle = 40 + 4 * (level),              -- angolo di visione in gradi (sx <- direzione -> dx)

            reaction_time = 0.75 - 0.15 * level,        -- tempo di reazione (ms) a seguito di visione
            aim_prediction_skill = 0.2 * level          -- capacità di mirare (predirre la posizione del target) -- can be from 0 to 1  // 5 difficulties 0, .25 .5 .75 1
            -- aim_accuracy = 4,                        -- accuratezza del mirare () ampiezza scostamento dal target
        }
    end

    function self.create(index, level)
        local team = self.defineTeams(index)
        -- Create bot object
        local sprite = team=='blue' and Sprites.blue_bot or Sprites.red_bot
        local bot = {
            index = math.random(1000000), -- id
            name = 'bot' .. #self.bots + 1,
            team = team,
            teamStatus = teams,
            type = 'actor',
            sprite = sprite,
            x = 0,
            y = 0,
            r = 0,
            velX = 0,
            velY = 0,

            w = sprite:getWidth(),
            h = sprite:getHeight(),
            speed = config.GAME.ACTORS_SPEED, -- pixels per second

            damage = 1, -- capacity to make damage (1 normal 4 for quad)

            kills = 0, -- enemy killed
            score = 0, -- punti per team_deathmatch & ctf
            numberOfDeaths = 0, -- numero di volte in vui è stato ucciso

            weaponsInventory = WeaponsInventory.new(),
            parameters = self.createPersonality(level),
            team_role = self.createRole(index), --  TODO per num di bot >3
            weapons_preferences = self.createWeaponPreferences(),

            attackCounter = 0,      -- frequenza di sparo

            nodes = {},             -- path to reach an item
            target = nil,            -- target for fighting
            best_powerup = {},      -- target of movement
            best_waypoint = {},     -- target of movement
            underAttack = false,    -- if underAttack turn to the bullet_collision_point

            info = ''               -- for debug
        }

        bot.reactionCounter = bot.parameters.reaction_time -- tempo di reazione una volta avvistato un nemico (x -> fight state)
        -- ai
        bot.brain = FsmMachine.new(bot)
        self.spawn(bot)
        table.insert(self.bots, bot)
    end

    function self.spawn(bot)
        bot.x, bot.y, bot.r = handlers.points.getRandomSpawnPoint()
        bot.hp = 100
        bot.ap = 0
        bot.alive = true
        bot.weaponsInventory.resetWeapons()
        world:add(bot, bot.x, bot.y, bot.w, bot.h) -- player bb is in the phisycs world

        -- ai
        bot.nodes = {}             -- path to reach an item
        bot.target = nil            -- target for fighting
        bot.best_powerup = {}      -- target of movement
        bot.best_waypoint = {}     -- target of movement
        bot.underAttack = false    -- if underAttack turn to the bullet_collision_point
        bot.last_visible_position = nil
    end

    function self.die(bot)
        bot.alive = false
        bot.numberOfDeaths = bot.numberOfDeaths + 1
        world:remove(bot) -- removing bot from the phisycs world
        Timer.after(10, function() self.spawn(bot) end)
    end

    function self.fire(p, dt)
        local w = p.weaponsInventory.selectedWeapon
        if p.alive and p.target and w.shotNumber > 0 then
            if p.attackCounter > 0 then
                p.attackCounter = p.attackCounter - 1 * dt * p.parameters.fire_throttle
            else
                -- bullet prediction -> how well bots are aiming!!
                local predvX = (p.target.x - p.target.old_x) / (p.target.speed * dt) / (p.speed * dt);
                local predvY = (p.target.y - p.target.old_y) / (p.target.speed * dt) / (p.speed * dt);
                -- print('Prediction :', tostring(predvX),tostring(predvY)) -- dell'ordine di +/- 0.25

                -- bot skill level
                predvX = math.random() < p.parameters.aim_prediction_skill and predvX or 0
                predvY = math.random() < p.parameters.aim_prediction_skill and predvY or 0

                local dist, dx, dy = helpers.dist(p, p.target)
                local velX = dx / dist + predvX
                local velY = dy / dist + predvY
                -- angle with target
                local angle = math.atan2(velY, velX)

                for _i = w.count, 1, -1 do
                    handlers.bullets.create(
                        {
                            x = p.x + (p.w / 2) + 48 * math.cos(angle),
                            y = p.y + (p.h / 2) + 48 * math.sin(angle)
                        }, angle, p)
                end
                p.attackCounter = w.frequency
            end
        else
            p.weaponsInventory.getBest()
        end
    end

    function self.update(self, dt)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]
            if bot.alive then bot.brain.update(dt) end
        end
    end

    function self.draw(self)
        for _i = #self.bots, 1, -1 do
            local bot = self.bots[_i]
            if bot.alive then
                love.graphics.draw(bot.sprite, math.floor(bot.x + bot.w / 2), math.floor(bot.y + bot.h / 2), bot.r, 1, 1, bot.w / 2, bot.h / 2)
                -- debug field of view
                if debug then
                    local delta = math.rad(bot.parameters.view_angle)
                    local vision_length = bot.parameters.view_length
                    love.graphics.setColor(0, 0.9, 0, 0.25)
                    love.graphics.arc("fill", bot.x + bot.w / 2, bot.y + bot.h / 2, vision_length, bot.r - delta, bot.r + delta)
                    love.graphics.setColor(0, 0.9, 0, 0.75)
                    love.graphics.arc("line", bot.x + bot.w / 2, bot.y + bot.h / 2, vision_length, bot.r - delta, bot.r + delta)
                    -- coordinates
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(bot.name, bot.x - 16, bot.y - 16)
                    -- love.graphics.print(math.floor(bot.x) .. ' ' ..  math.floor(bot.y), bot.x, bot.y + 32)
                    -- love.graphics.print("Angle: " .. tostring(bot.r), bot.x - 16, bot.y + 48)
                    love.graphics.print("State: " .. tostring(bot.brain.curState.stateName), bot.x - 16, bot.y + 48)
                    love.graphics.print("Team: " .. bot.team ..' - '..bot.team_role, bot.x - 16, bot.y -24)
                    if bot.target then
                        love.graphics.print("Target: " .. bot.target.name, bot.x -16, bot.y + 64)
                    elseif bot.best then
                        love.graphics.print("Target ID: " .. bot.best.id, bot.x -16, bot.y + 64)
                    end
                end
                -- debug path
                if debug and bot.nodes and #bot.nodes then
                    -- points to cursor
                    for i = 2, #bot.nodes, 1 do
                        local n = bot.nodes[i]
                        local nm = bot.nodes[i - 1]
                        local a = {x = 0, y = 0}
                        local am = {x = 0, y = 0}
                        am.x, am.y = handlers.pf.tileToWorld(nm.x, nm.y)
                        a.x, a.y = handlers.pf.tileToWorld(n.x, n.y)
                        -- linea rossa tiene conto dell'offset al centro del player
                        love.graphics.setColor(1, 0, 0, 1)
                        love.graphics.circle('fill', am.x + 16, am.y + 16, 4)
                        love.graphics.line(am.x + 16, am.y + 16, a.x + 16, a.y + 16)
                        -- linea gialla tiles del path
                        love.graphics.setColor(1, 1, 0, 1)
                        love.graphics.circle('fill', a.x, a.y, 4)
                        love.graphics.line(am.x, am.y, a.x, a.y)
                        love.graphics.rectangle('line', am.x, am.y, 32, 32)
                    end
                end
            end
        end
    end

    return self

end

return BotsHandler

