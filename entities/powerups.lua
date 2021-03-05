local PowerupsHandler = {}

PowerupsHandler.new = function()

    local self = map:addCustomLayer("Powerups", 5)

    local tipiPowerUp = {
        -- powerups
        health = {
            name = 'health',
            hp = 5,
            spawnTime = 30,
            sprite = Sprites.powerup_health
        },
        megaHealth = {
            name = 'megaHealth',
            hp = 50,
            spawnTime = 30,
            sprite = Sprites.powerup_megaHealth
        },
        armour = {
            name = 'armour',
            ap = 5,
            spawnTime = 30,
            sprite = Sprites.powerup_armour
        },
        megaArmour = {
            name = 'megaArmour',
            ap = 50,
            spawnTime = 30,
            sprite = Sprites.powerup_megaArmour
        },
        quad = {
            name = 'quad',
            multiplier = 4,
            spawnTime = 150,
            enterAfter = 60,
            duration = 10,
            sprite = Sprites.powerup_quad
        },
        speed = {
            name = 'speed',
            multiplier = 1.5,
            spawnTime = 150,
            enterAfter = 30,
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
                object.info = tipiPowerUp[object.name]
                object.inCheck = false
                -- if special collectable
                if object.info.enterAfter ~= nil then
                    Timer.after(object.info.enterAfter,
                                function()
                        object.visible = true
                    end)
                else
                    object.visible = true
                end
                -- if ammo or weapon
                if object.info.of ~= nil and
                    (object.info.type == 'ammo' or object.info.type == 'weapon') then
                    object.amount = object.info.amount
                    object.of = object.info.of
                    object.type = object.info.type
                end
                world:add(object, object.x, object.y, object.width,
                          object.height) -- powerups is in the phisycs world
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
        end
    end

    function self.draw(self)
        for k, object in pairs(self.powerups) do
            if (object.visible) then
                love.graphics.draw(object.info.sprite, math.floor(object.x), math.floor(object.y), 0, 1, 1)
                if debug then
                    love.graphics.setFont(Fonts.sm)
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

    return self
end

return PowerupsHandler
