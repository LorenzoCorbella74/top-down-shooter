local WeaponsInventory = {}

WeaponsInventory.new = function()
    local self = {}

    -- private
    local weapons = {
        Rifle = {
            sprite = 'TBD', -- image
            frequency = 200, --  è la frequenza di sparo = colpi al sec
            count = 1, --  NUMERO DI PARTICELLE PER OGNI COLPO
            speed = 9, --  VELOCITA'

            ttl = 1000, --  VITA (DURATA DEL COLPO)
            explode = 0, --  SE CREA UNA ESPLOSIONE
            spread = 0.1, --  QUANTO SI ALLARGA
            damage = 5, --  DANNO INFLITTO
            --  destroy = false,     --  SE DISTRUGGE
            available = true, --  SE L'ARMA E' DISPONIBILE
            shotNumber = 100 --  numero di colpi iniziale
        },
        Shotgun = {
            sprite = 'TBD', -- image
            frequency = 800,
            count = 6,
            speed = 9,
            r = 2,
            color = '#800000',
            ttl = 1000,
            explode = 0,
            spread = 0.5,
            damage = 10,
            --  destroy = false,
            available = false,
            shotNumber = 0 --  60
        },
        Plasma = {
            sprite = 'TBD', -- image
            frequency = 150,
            count = 1,
            speed = 10,
            r = 3,
            color = 'blue',
            ttl = 1400,
            explode = 0,
            spread = 0.01,
            damage = 3,
            --  destroy = false,
            available = false,
            shotNumber = 0 --  80
        },
        Rocket = {
            sprite = 'TBD', -- image
            frequency = 1000,
            count = 1,
            speed = 8,
            r = 4,
            color = 'red',
            ttl = 1500,
            explode = 1,
            spread = 0.01,
            damage = 65,
            -- destroy = true,
            available = false,
            shotNumber = 10
        },
        Railgun = {
            sprite = 'TBD', -- image
            frequency = 2000,
            count = 1,
            speed = 16,
            r = 3,
            color = 'green',
            ttl = 1500,
            explode = 0,
            spread = 0.01,
            damage = 110,
            -- destroy = false,
            available = false,
            shotNumber = 0 --  100
        }
    }

    self.selectedWeapon = weapons['Rifle']; -- default

    function self.setWeapon(name) self.selectedWeapon = weapons[name] end

    -- TODO = si prende in base a probabilità pesata delle preferenze del bot e alla disponibilità
    function self.getBest()
        for i = #weapons, 1, -1 do
            local weapon = weapons[i]
            if weapon.available and weapon.shotNumber > 0 then
                self.selectedWeapon = weapon
                break
            end
        end
    end

    -- dopo un respawn le munizioni vengono azzerate
    -- e rimossa la disponibilità delle armi
    function self.resetWeapons()
        for i = #weapons, 1, -1 do
            local weapon = weapons[i]
            weapon.shotNumber = 0;
            weapon.available = false;
        end
        -- defaults
        weapons[0].shotNumber = 100;
        weapons[0].available = true;
    end

    -- quando si colleziona un'arma e una cassa di munizioni
    function self.setAvailabilityAndNumOfBullets(name, numOfBullet)
        local weapon = weapons[name]
        weapon.shotNumber = weapon.shotNumber + numOfBullet;
        weapon.available = true;
    end

    function self.setNumOfBullets(name, numOfBullet)
        local weapon = weapons[name]
        weapon.shotNumber = weapon.shotNumber + numOfBullet;
    end

    return self
end

return WeaponsInventory
