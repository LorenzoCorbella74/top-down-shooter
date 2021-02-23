local WeaponsInventory = {}

WeaponsInventory.new = function()
    local self = {}

    -- weapon DB
    self.weapons = {
        {
            name = 'Rifle',
            sprite = Sprites.bullet_Rifle, -- image for bullet
            frequency = 200, --  è la frequenza di sparo = colpi al sec
            count = 1, --  NUMERO DI PARTICELLE PER OGNI COLPO
            speed = 900, --  VELOCITA'

            ttl = 0.5, --  VITA (DURATA DEL COLPO)
            explode = 0, --  SE CREA UNA ESPLOSIONE
            spread = 0.1, --  QUANTO SI ALLARGA
            damage = 5, --  DANNO INFLITTO
            --  destroy = false,            --  SE DISTRUGGE
            available = true, --  SE L'ARMA E' DISPONIBILE
            shotNumber = 100 --  numero di colpi iniziale
        }, {
            name = 'Shotgun',
            sprite = Sprites.bullet_Shotgun, -- image for bullet
            frequency = 800,
            count = 6,
            speed = 900,
            r = 2,
            color = '#800000',
            ttl = 0.35,
            explode = 0,
            spread = 0.5,
            damage = 10,
            --  destroy = false,
            available = true,
            shotNumber = 10 --  60
        }, {
            name = 'Plasma',
            sprite = Sprites.bullet_Plasma, -- image for bullet
            frequency = 150,
            count = 1,
            speed = 1200,
            r = 3,
            color = 'blue',
            ttl = 0.5,
            explode = 0,
            spread = 0.01,
            damage = 3,
            --  destroy = false,
            available = true,
            shotNumber = 10 --  80
        }, {
            name = 'Rocket',
            sprite = Sprites.bullet_Rocket, -- image for bullet
            frequency = 1000,
            count = 1,
            speed = 800,
            r = 4,
            color = 'red',
            ttl = 1,
            explode = 1,
            spread = 0.01,
            damage = 65,
            -- destroy = true,
            available = true,
            shotNumber = 10
        }, {
            name = 'Railgun',
            sprite = Sprites.bullet_Railgun, -- image for bullet
            frequency = 2000,
            count = 1,
            speed = 1600,
            r = 3,
            color = 'green',
            ttl = 1.5,
            explode = 0,
            spread = 0.01,
            damage = 110,
            -- destroy = false,
            available = true,
            shotNumber = 10 --  100
        }
    }

    self.selectedWeapon = self.weapons[1]; -- default
    -- self.selectedWeapon = self.setWeapon('Rifle'); -- default

    function self.setWeapon(name)
        for i = #self.weapons, 1, -1 do
            local weapon = self.weapons[i]
            if weapon.name == name then
                self.selectedWeapon = weapon
                break
            end
        end
    end

    function self.getWeapon(name)
        for i = #self.weapons, 1, -1 do
            local weapon = self.weapons[i]
            if weapon.name == name then return weapon, i end
        end
    end

    -- TODO = si prende in base a probabilità pesata delle preferenze del bot e alla disponibilità
    function self.getBest()
        for i = #self.weapons, 1, -1 do
            local weapon = self.weapons[i]
            if weapon.available and weapon.shotNumber > 0 then
                self.selectedWeapon = weapon
                break
            end
        end
    end

    -- dopo un respawn le munizioni vengono azzerate
    -- e rimossa la disponibilità delle armi
    function self.resetWeapons()
        for i = #self.weapons, 1, -1 do
            local weapon = self.weapons[i]
            weapon.shotNumber = 0;
            weapon.available = false;
        end
        -- defaults
        self.weapons[1].shotNumber = 100;
        self.weapons[1].available = true;
    end

    -- quando si colleziona un'arma e una cassa di munizioni
    function self.setAvailabilityAndNumOfBullets(name, numOfBullet)
        local weapon = self.getWeapon(name)
        weapon.shotNumber = weapon.shotNumber + numOfBullet;
        weapon.available = true;
    end

    function self.setNumOfBullets(name, numOfBullet)
        local weapon = self.getWeapon(name)
        weapon.shotNumber = weapon.shotNumber + numOfBullet;
    end

    return self
end

return WeaponsInventory
