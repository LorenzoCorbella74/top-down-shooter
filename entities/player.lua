-- require "..helpers.boundingbox"
local WeaponsInventory = require "entities.weapons" -- loading weaponsInventory
local helpers = require "..helpers.helpers"

local PlayerHandler = {}

PlayerHandler.new = function()

    local self = map:addCustomLayer("Sprites", 4)

    function self.create()
        -- Create player object
        local sprite = Sprites.player
        self.player = {
            index = math.random(1000000), -- id
            name = 'player',
            team = 'player',
            type = 'actor',
            sprite = sprite,
            w = sprite:getWidth(),
            h = sprite:getHeight(),
            speed = 256, -- pixels per second

            damage = 1, -- capacity to make damage (1 normal 4 for quad)

            kills = 0, -- enemy killed
            score = 0, -- numero di uccisioni
            numberOfDeaths = 0, -- numero di volte in vui è stato ucciso

            weaponsInventory = WeaponsInventory.new(),

            attackCounter = 0 -- frequenza di sparo
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
        p.numberOfDeaths = p.numberOfDeaths + 1
        -- animazione morte
        world:remove(p)
        --[[ show countdown timer ]]
        Timer.after(10, function()
            handlers.camera.setCameraOnActor(p)
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

        helpers.checkCollision(p,futurex, futurey)

        -- player rotation
        local mx, my = camera:getMousePosition()
        p.r = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))
    end

    function self.draw(self)
        -- Draw player
        local p = self.player
        love.graphics.draw(p.sprite, p.x + p.w / 2, p.y + p.h / 2, p.r, 1, 1, p.w / 2, p.h / 2)
        -- cursor
        local mx, my = camera:getMousePosition()
        love.graphics.line(mx, my - 16, mx, my + 16)
        love.graphics.line(mx - 16, my, mx + 16, my)
        -- debug
        if debug then
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.setFont(Fonts.sm)
            love.graphics.rectangle('line', p.x, p.y, p.w, p.h)
            -- coordinates
            love.graphics.print(math.floor(p.x) .. ' ' .. math.floor(p.y), p.x, p.y + 32)
            -- line to cursor
            love.graphics.line(p.x + p.w / 2, p.y + p.h / 2, mx, my)
            -- coordinates and angle with mouse
            love.graphics.print(math.floor(mx) .. ' ' .. math.floor(my), mx - 16, my + 16)
            love.graphics.print(math.floor(mx) .. ' ' .. math.floor(my), mx - 16, my + 16)
            love.graphics.print("Angle: " .. tostring(math.deg(p.r)), mx - 16, my + 32)
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

        -- path
        if debug and p.nodes and #p.nodes then
            -- points to cursor
            for i = 2, #p.nodes, 1 do
                local n = p.nodes[i]
                local nm = p.nodes[i - 1]
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

                -- debugging collision map
                --[[ local tw = handlers.pf.starting_map.tilewidth
                local nw = handlers.pf.starting_map.width
                local th = handlers.pf.starting_map.tileheight
                local nh = handlers.pf.starting_map.height
                for y = 1, nw, 1 do
                    for x = 1, nh, 1 do
                        if handlers.pf.collisionMap[y][x] == 0 then
                            love.graphics.setColor(0.5, 0.5, 0.5, 0.1)
                        else
                            love.graphics.setColor(0, 0, 1, 1)
                        end
                        love.graphics.rectangle('line', (x-1) * tw, (y-1) * th, tw, th)
                    end
                end ]]
            end
        end

    end

    function self.fire(dt)
        local p = self.player
        -- p.nodes = {}
        local w = p.weaponsInventory.selectedWeapon
        if p.alive and w.shotNumber > 0 then

            if p.attackCounter > 0 then
                p.attackCounter = p.attackCounter - 1 * dt
            else
                -- Gets the position of the mouse in world coordinates 
                -- equivals to camera:toWorldCoords(love.mouse.getPosition())
                local mx, my = camera:getMousePosition()
                local angle = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))

                for _i = w.count, 1, -1 do
                    handlers.bullets.create(
                        {
                            x = p.x + p.w / 2 + 32 * math.cos(angle),
                            y = p.y + p.h / 2 + 32 * math.sin(angle)
                        }, angle, p)
                end
                p.attackCounter = w.frequency
            end

            -- test path finding
            -- non si capisce come mai si debba aumentare di 1 le coordinate di inizio e finder
            -- e poi si deve togliere 1 dai nodi calcolati
            --[[ local startx, starty = handlers.pf.worldToTile(p.x + p.w / 2 + 32, p.y + p.h / 2 + 32)
            local finalx, finaly = handlers.pf.worldToTile(mx + 32, my+32)
            p.path = handlers.pf.calculatePath(startx, starty, finalx,finaly)
            if p.path then
                print(('Path found! Length: %.2f'):format(p.path:getLength()))
                for node, count in p.path:nodes() do
                    print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
                    table.insert(p.nodes, {x = node:getX()-1, y = node:getY()-1})
                end
            end ]]
        else
            p.weaponsInventory.getBest()
        end

    end

    return self
end

return PlayerHandler

