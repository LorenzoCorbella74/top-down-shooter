-- require "..helpers.boundingbox"
local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory

local PlayerHandler = {}

PlayerHandler.new = function(game)

    local self = map:addCustomLayer("Sprites", 4)
    self.game = game -- reference to game state

    local playerFilter = function(item, other)
        if other.name == 'health' and other.visible then
            return 'cross'
        else
            return 'slide'
        end
    end

    function self.init()
        -- Create player object
        local sprite = Sprites.player
        self.player = {
            index = math.random(1000000), -- id
            name = 'player',
            team = 'player',
            sprite = sprite,
            w = sprite:getWidth(),
            h = sprite:getHeight(),
            speed = 256, -- pixels per second

            damage = 1, -- capacity to make damage (1 normal 4 for quad)

            kills = 0, -- enemy killed
            score = 0, -- numero di uccisioni
            numberOfDeaths = 0, -- numero di volte in vui è stato ucciso

            weaponsInventory = WeaponsInventory.new()
            --[[ attackCounter: number = 0;		// frequenza di sparo
        // shootRate:     number = 200;	// frequenza di sparo ]]
        }
        self.spawn()
    end

    function self.spawn()
        local p = self.player
        p.x, p.y, p.r = handlers.points.getRandomSpawnPoint()
        p.hp = 100
        p.ap = 0
        p.alive = true
        p.weaponsInventory.resetWeapons()
        world:add(p, p.x, p.y, p.w, p.h) -- player bb is in the phisycs world
    end

    function self:die()
        local p = self.player
        p.alive = false
        world:remove(p) -- removing player from the phisycs world
        --[[ show countdown timer ]]
        Timer(10, function()
            self.game.setCameraOnActor(p)
            self.spawn()
        end)
    end

    -- Add controls to player
    function self.update(self, dt)
        local p = self.player
        local futurex = p.x
        local futurey = p.y
        -- Move player up
        if love.keyboard.isDown("w", "up") then
            futurey = p.y - p.speed * dt
        end
        -- Move player down
        if love.keyboard.isDown("s", "down") then
            futurey = p.y + p.speed * dt
        end
        -- Move player left
        if love.keyboard.isDown("a", "left") then
            futurex = p.x - p.speed * dt
        end
        -- Move player right
        if love.keyboard.isDown("d", "right") then
            futurex = p.x + p.speed * dt
        end

        p.old_x = p.x
        p.old_y = p.y

        local cols, cols_len
        -- update the player associated bounding box in the world
        p.x, p.y, cols, cols_len = world:move(p, futurex, futurey, playerFilter)

        --[[ collisions ]]
        for i = 1, cols_len do
            local item = cols[i].other
            local col = cols[i]
            if (item.type == 'powerups' and item.visible) then
                handlers.powerups.applyPowerup(item, self.player)
            end
            if (item.type == 'ammo' and item.visible) then
                handlers.powerups.applyAmmo(item, self.player)
            end
            if (item.type == 'weapons' and item.visible) then
                handlers.powerups.applyWeapon(item, self.player)
            end
            print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(
                      col.other, col.type, col.normal.x, col.normal.y))
        end

        -- player rotation
        local mx, my = camera:getMousePosition()
        p.r = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))
    end

    function self.draw(self)
        -- Draw player
        local p = self.player
        local mx, my = camera:getMousePosition()
        love.graphics.draw(p.sprite, p.x + p.w / 2, p.y + p.h / 2, p.r, 1, 1,
                           p.w / 2, p.h / 2)
        -- cursor
        love.graphics.line(mx, my - 16, mx, my + 16)
        love.graphics.line(mx - 16, my, mx + 16, my)
        -- debug
        if debug then
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle('line', p.x, p.y, p.w, p.h)
            -- line to cursor
            love.graphics.line(p.x + p.w / 2, p.y + p.h / 2, mx, my) -- origin is NOT moved
            love.graphics.setFont(Fonts.sm)
            love.graphics.print(math.floor(mx) .. ' ' .. math.floor(my),
                                mx - 16, my + 16)
        end
        -- debug for all collidable rectangles
        -- must be placed in the last layer of the map!!!
        if debug then
            love.graphics.setColor(1, 1, 1, 1)
            local items, len = world:getItems()
            for i = 1, len do
                local x, y, w, h = world:getRect(items[i])
                love.graphics.rectangle("line", x, y, w, h)
            end
        end
    end

    function self.fire()
        local p = self.player
        local w = p.weaponsInventory.selectedWeapon
        if p.alive and w.shotNumber > 0 then
            -- Gets the position of the mouse in world coordinates 
            -- equivals to camera:toWorldCoords(love.mouse.getPosition())
            local mx, my = camera:getMousePosition()
            local angle = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))

            for _i = w.count, 1, -1 do
                handlers.bullets.create({
                    x = p.x + p.w / 2 + 32 * math.cos(angle),
                    y = p.y + p.h / 2 + 32 * math.sin(angle)
                }, angle, p)
            end

            local start = {}
            local final = {}
            start.x, start.y = map:jumper_getCoord(p.x, p.y)
            final.x, final.y = map:jumper_getCoord(mx, my)
            p.path = map:jumper_calculatePath(start.x, start.y, final.x, final.y)
        else
            p.weaponsInventory.getBest()
        end

    end

    return self
end

return PlayerHandler

