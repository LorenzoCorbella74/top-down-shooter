-- require "..helpers.boundingbox"

local WeaponsInventory = require "entities.weapons"  -- loading  weaponsInventory

function CreatePlayer()
    local layer = map:addCustomLayer("Sprites", 4)

    -- Get player spawn object
    local player
    for k, object in pairs(map.objects) do
        print(k)
        if object.name == "spawn" then
            player = object
            break
        end
    end

    local playerFilter = function(item, other)
        if other.name == 'health' and other.visible then
            return 'cross'
        else
            return 'slide'
        end
    end

    -- Create player object
    local sprite = Sprites.player
    layer.player = {
        index = math.random(1000000),  -- id
        name = 'player',
        team = 'player',
        sprite = sprite,
        x = player.x,
        y = player.y,
        w = sprite:getWidth(),
        h = sprite:getHeight(),

        r = 0,              -- rotation angle (radians)
        speed = 256,        -- pixels per second

        hp = 100,
        ap = 0,
        alive = true,
        respawnTime = 0,
        damage = 1,                 -- capacity to make damage (1 normal 4 for quad)

        kills = 0,                  -- enemy killed
        score = 0,			        -- numero di uccisioni
        numberOfDeaths = 0,	        -- numero di volte in vui è stato ucciso
        
        godMode = false,
    
        weaponsInventory = WeaponsInventory.new(),
        --[[ attackCounter: number = 0;		// frequenza di sparo
        // shootRate:     number = 200;	// frequenza di sparo ]]
    }

    local p = layer.player

    world:add(layer.player, p.x, p.y, p.w, p.h) -- player bb is in the phisycs world

    -- Add controls to player
    layer.update = function(self, dt)

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

        for i = 1, cols_len do
            local item = cols[i].other
            local col = cols[i]
            if (item.type == 'powerups' and item.visible) then
                handlers.powerups.applyPowerup(item, self.player)
            end
            if (item.type == 'ammos' and item.visible) then
                handlers.powerups.applyAmmo(item, self.player)
            end
            if (item.type == 'weapons' and item.visible) then
                handlers.powerups.applyWeapon(item, self.player)
            end
            print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x, col.normal.y))
        end

        -- player rotation
        local mx, my = camera:getMousePosition()
        p.r = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))
    end

    layer.draw = function(self)
        -- Draw player
        local p = self.player
        local mx, my = camera:getMousePosition()
        love.graphics.draw(p.sprite, p.x + p.w / 2, p.y + p.h / 2, p.r, 1, 1,p.w / 2, p.h / 2)
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
            love.graphics.print(math.floor(mx) .. ' ' .. math.floor(my), mx - 16, my + 16)
        end
        -- debug for all collidable rectangles
        if debug then
            love.graphics.setColor(1, 1, 1, 1)
            local items, len = world:getItems()
            for i = 1, len do
                local x, y, w, h = world:getRect(items[i])
                love.graphics.rectangle("line", x, y, w, h)
            end
        end

    end

    return layer
end

