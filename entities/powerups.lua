local config = require "config"
local teams = require "../helpers.teams"        -- simple shared table

local PowerupsHandler = {}

PowerupsHandler.new = function()

    local self = map:addCustomLayer("Powerups", 5)

    local tipiPowerUp = {
        -- flags
        blue_flag={
            name = 'blue_flag',
            type = 'flag',
            reference= 'team1',
            sprite = Sprites.blue_flag
        },
        red_flag={
            name = 'red_flag',
            reference= 'team2',
            type = 'flag',
            sprite = Sprites.red_flag
        },
        -- powerups
        health = {
            name = 'health',
            hp = 5,
            spawnTime = 30,
            type = 'health',
            sprite = Sprites.powerup_health
        },
        megaHealth = {
            name = 'megaHealth',
            type = 'special_powerup',
            hp = 50,
            spawnTime = 30,
            sprite = Sprites.powerup_megaHealth
        },
        armour = {
            name = 'armour',
            type = 'health',
            ap = 5,
            spawnTime = 30,
            sprite = Sprites.powerup_armour
        },
        megaArmour = {
            name = 'megaArmour',
            type = 'special_powerup',
            ap = 50,
            spawnTime = 30,
            sprite = Sprites.powerup_megaArmour
        },
        quad = {
            name = 'quad',
            type = 'special_powerup',
            multiplier = 4,
            spawnTime = 150,
            enterAfter = 60,
            duration = 10,
            sprite = Sprites.powerup_quad
        },
        speed = {
            name = 'speed',
            type = 'special_powerup',
            multiplier = 1.5,
            spawnTime = 150,
            enterAfter = 60,
            duration = 10,
            sprite = Sprites.powerup_speed
        },
        -- ammo packs
        ammoRifle = {
            of = 'Rifle',
            spawnTime = 30,
            amount = 30,
            sprite = Sprites.ammo_Rifle,
            type = 'ammo'
        },
        ammoShotgun = {
            of = 'Shotgun',
            spawnTime = 30,
            amount = 24,
            type = 'ammo'
        },
        ammoPlasma = {of = 'Plasma', spawnTime = 30, amount = 25, type = 'ammo'},
        ammoRocket = {of = 'Rocket', spawnTime = 30, amount = 5, type = 'ammo'},
        ammoRailgun = {
            of = 'Railgun',
            spawnTime = 30,
            amount = 5,
            type = 'ammo'
        },
        -- weapons
        weaponShotgun = {
            of = 'Shotgun',
            spawnTime = 30,
            amount = 24,
            type = 'weapon'
        },
        weaponPlasma = {
            of = 'Plasma',
            spawnTime = 30,
            amount = 25,
            type = 'weapon'
        },
        weaponRocket = {
            of = 'Rocket',
            spawnTime = 30,
            amount = 5,
            type = 'weapon'
        },
        weaponRailgun = {
            of = 'Railgun',
            spawnTime = 30,
            amount = 5,
            type = 'weapon'
        }
    }

    self.powerups = {}

    function self.init()
        for k, object in pairs(map.objects) do
            if tipiPowerUp[object.name] ~= nil then
                -- object.id is coming from map built with "tiled" software
                object.info = tipiPowerUp[object.name]
                local sprite = object.info.sprite
                object.w = sprite:getWidth()
                object.h = sprite:getHeight()
                object.inCheck = false
                -- if special collectable
                if object.info.enterAfter ~= nil then
                    object.visible = false
                    Timer.after(object.info.enterAfter,
                                function()
                        object.visible = true
                    end)
                else
                    object.visible = true
                end
                -- if ammo or weapon
                if object.info.of ~= nil and (object.info.type == 'ammo' or object.info.type == 'weapon') then
                    object.amount = object.info.amount
                    object.of = object.info.of
                    object.type = object.info.type
                end
                -- if flags
                if object.info.name=='blue_flag' or object.info.name=='red_flag' then
                    object.originx = object.x
                    object.originy = object.y
                    -- set flags in teams shared table
                    teams[object.info.name=='blue_flag' and 'team2' or 'team1'].enemyFlag = object
                end
                world:add(object, object.x, object.y, object.w, object.h) -- powerups is in the phisycs world
                table.insert(self.powerups, object)
            end
        end
    end

    function self.update(self, dt)
        for i = #self.powerups, 1, -1 do
            local object = self.powerups[i]
            if not object.visible and not object.inCheck then
                object.inCheck = true
                -- back to game
                Timer.after(object.info.spawnTime, function()
                    world:add(object, object.x, object.y, object.width, object.height) -- powerups is in the phisycs world again
                    object.inCheck = false
                    object.visible = true
                end)
            end
            if object.actorToBeFollowed ~= nil then
                object.x = object.actorToBeFollowed.x - 8
                object.y = object.actorToBeFollowed.y - 16
            end
        end
    end

    function self.draw(self)
        for k, object in pairs(self.powerups) do
            if (object.visible) then
                love.graphics.draw(object.info.sprite, math.floor(object.x), math.floor(object.y), 0, 1, 1)
                if debug then
                    love.graphics.setFont(Fonts.sm)
                    love.graphics.print('ID:'..math.floor(object.id), object.x - 16, object.y - 16)
                    love.graphics.print(math.floor(object.x) .. ' ' .. math.floor(object.y), object.x - 16, object.y + 16)
                end
            end
        end
    end

    function self.applyPowerup(powerup, who)
        -- camera:shake(12, 1, 60) only if player
        world:remove(powerup) -- powerup is no more in the phisycs world
        powerup.takenBy = who
        if powerup.info.name == 'health' then
            who.hp = who.hp + powerup.info.hp;
        elseif powerup.info.name == 'armour' then
            who.ap = who.ap + powerup.info.ap;
        elseif powerup.info.name == 'megaHealth' then
            who.hp = who.hp + powerup.info.hp;
        elseif powerup.info.name == 'megaArmour' then
            who.ap = who.ap + powerup.info.ap;
        elseif powerup.info.name == 'quad' then
            who.damage = who.damage * powerup.info.multiplier;
            -- apply effect
            Timer.after(powerup.info.duration, function()
                who.damage = who.damage / powerup.info.multiplier;
            end)
        elseif powerup.info.name == 'speed' then
            who.speed = who.speed * powerup.info.multiplier;
            -- remove effect
            Timer.after(powerup.info.duration, function()
                who.speed = who.speed / powerup.info.multiplier;
            end)
        end
        powerup.visible = false
    end

    function self.applyAmmo(powerup, who)
        world:remove(powerup) -- powerup is no more in the phisycs world
        who.weaponsInventory.setAvailabilityAndNumOfBullets(powerup.of,powerup.amount);
        powerup.visible = false
    end

    function self.applyWeapon(powerup, who)
        world:remove(powerup) -- powerup is no more in the phisycs world
        who.weaponsInventory.setNumOfBullets(powerup.of, powerup.amount);
        powerup.visible = false
    end


    -- enemy flag when taken follow the actor
    function self.followActor(item, actor)
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            if powerup.id == item.id then
                powerup.actorToBeFollowed = actor
                world:remove(powerup) -- flag is no more in the phisycs world
                break
            end
        end
    end

    -- enemy flag position is restored after scoring or left when carrier is dead
    function self.unFollowActor(item, backToOrigin)
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            if powerup.id == item.id then
                powerup.actorToBeFollowed = nil
                if backToOrigin then
                    item.x = item.originx
                    item.y = item.originy
                end
                world:add(item, item.x, item.y, item.w, item.h) -- flag is in the phisycs world
                break
            end
        end
    end

    -- enemy flag position is restored after scoring or left when carrier is dead
    function self.backToBase(item)
        item.x = item.originx
        item.y = item.originy    
        world:update(item, item.x, item.y, item.w, item.h) -- flag is in the phisycs world
    end

    -- powerup visibility for each bot
    -- when it's taken it's no more visible and a timer is called
    -- after x sec the powerup is once again visible
    function self.seedBotsInPowerups(players)
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            powerup.players = {}
            for y = #players, 1, -1 do
                local player = players[y]
                powerup.players[player.index] = {visible = true}
            end
        end
    end

    function self.trackBot(id, bot)
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            if powerup.id == id then
                if powerup.info.type ~='flag' then
                    powerup.players[bot.index].visible = false
                    Timer.after(config.GAME.WAYPOINTS_TIMING, function()
                        powerup.players[bot.index].visible = true
                    end)
                else
                    -- flag is always visible
                    powerup.players[bot.index].visible = true
                end
            end
        end
    end

    return self
end

return PowerupsHandler
