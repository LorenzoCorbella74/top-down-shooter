PointsHandler    = require "entities.points"          -- handler for spawnPoints, waypoints
PlayerHandler    = require "entities.player"          -- handler for player
PowerupsHandler  = require "entities.powerups"        -- handler for powerups
BulletsHandler   = require "entities.bullets"         -- handler for bullets

local countdown = require "..helpers.countdown"

PathfindHandler = require "..helpers.pathfinding"



local state = {lastChangeWeaponTime = 0, currentCameraTarget = {}, message = 'message'}

-- init is called only once
-- enter is called when push
-- restore is called when pop
function state:enter()

    camera = Camera()
    camera:setFollowStyle('TOPDOWN')

    mousepressed = false

    love.mouse.setVisible(false)
    camera:setFollowLerp(0.2)
    camera:setFollowLead(10)

    map = sti("maps/dm1.lua", {'bump'})    -- Load map file
    world = bump.newWorld(32)                       -- defining the world for collisions
    map:bump_init(world)
    
    handlers = {}

    -- spawn_points and bots waypoints
    handlers.points = PointsHandler.new()
    handlers.points.getPointsFromMap()

    -- path finding helpers for jumper
    local map_for_jumper = require('maps/dm'..tostring(1))
    handlers.pf = PathfindHandler.new(map_for_jumper, 'walls', 0, 'JPS')

    -- player
    handlers.player = PlayerHandler.new(state)
    handlers.player.init()

    -- powerups
    handlers.powerups = PowerupsHandler.new()
    handlers.powerups.init()

    -- Bullets
    handlers.bullets = BulletsHandler.new()

    -- Remove unneeded object layer from map
    map:removeLayer("Spawn_points")
    map:removeLayer("powerups")
    map:removeLayer("waypoints")

    -- default camera is following the player
    self.setCameraOnActor(handlers.player.player)

    -- after the matchDuration go to game over screen
    GameCountdown = countdown.new(120)
end

-- set camera as method of game
function state.setCameraOnActor(actor) state.currentCameraTarget = actor end

-- set game message
function state.setMsg(msg) state.message = msg end

function state:update(dt)
    -- if love.mouse.isDown(1) then fire() end TODO
    map:update(dt) -- Update internally all map layers
    camera:update(dt)
    camera:follow(state.currentCameraTarget.x, state.currentCameraTarget.y)
    Timer.update(dt)
    GameCountdown.update(dt)
end

function state:draw()
    camera:attach()

    -- Draw your game here
    local scale = 1 -- Scale world with camera.scale

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local mapMaxWidth = map.width * map.tilewidth
    local mapMaxHeight = map.height * map.tileheight
    local x = math.min(math.max(0, camera.x - windowWidth / 2), mapMaxWidth - windowWidth)
    local y = math.min(math.max(0, camera.y - windowHeight / 2), mapMaxHeight - windowHeight)

    map:draw(-x, -y, scale, scale)

    camera:detach()
    camera:draw()
    drawHUD()
end

function state:keyreleased(key, code)
    if key == 'p' then Gamestate.push(PauseScreen, 1) end
    if key == 'escape' then Gamestate.pop(1) end
    if key == 'e' then camera:shake(8, 1, 60) end --  working BUT NOT PERFECT !!!
    if key == 'f' then camera:flash(0.15, {1, 0, 0, 1}) end -- working
    if key == 'i' then debug = not debug end
    if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
        local key = tonumber(key)
        local p = map.layers["Sprites"].player
        local w = p.weaponsInventory.weapons[key]
        -- weapon is set as current weapons if available
        if w.available and w.shotNumber > 0 then
            p.weaponsInventory.selectedWeapon = w
        end
    end
end

function love.wheelmoved(x, y)
    local now = love.timer.getTime()
    if now - state.lastChangeWeaponTime > 0.35 then
        state.lastChangeWeaponTime = now
        local p = map.layers["Sprites"].player
        local w = p.weaponsInventory.selectedWeapon
        local current, i = p.weaponsInventory.getWeapon(w.name)
        if y > 0 then
            if i <= 1 then
                i = #p.weaponsInventory.weapons
            else
                i = i - 1;
            end
        elseif y < 0 then
            if i >= #p.weaponsInventory.weapons then
                i = 1
            else
                i = i + 1;
            end
        end
        local c = p.weaponsInventory.weapons[i]
        -- weapon is set as current weapons if available
        if c.available and c.shotNumber > 0 then
            p.weaponsInventory.selectedWeapon = c
        end
    end
end

--[[ function state:leave()
    map = nil
    world = nil
    camera = nil
    currentCameraTarget = nil
end ]]

function state:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        mousepressed = true
        handlers.player.fire()
    end
end

function state:mousereleased(x, y, button, istouch, presses)
    if button == 1 then mousepressed = true end
end

function drawHUD()
    love.graphics.setFont(Fonts.md)
    local p = map.layers["Sprites"].player
    local w = p.weaponsInventory.selectedWeapon
    -- Player data
    love.graphics.print("HP:" .. tostring(p.hp), 32, 32)
    love.graphics.print("AP:" .. tostring(p.ap), 128, 32)
    love.graphics.print("Kills:" .. tostring(p.kills), 192, 32)
    -- current weapon and available shoots
    love.graphics.print(w.name .. ':' .. w.shotNumber, 288, 32)
    -- FPS
    local fps = love.timer.getFPS()
    love.graphics.print("FPS:" .. tostring(fps), love.graphics.getWidth() - 96, 32)
    -- Time of the current match
    love.graphics.printf("Time: " .. tostring(GameCountdown.show()),(love.graphics.getWidth() / 2) - 64, 32, 200, "center")
    -- game message
    love.graphics.printf("MSG: " ..state.message,(love.graphics.getWidth() / 2) - 64, 64, 200, "center")
    -- debug
    if debug then
        love.graphics.setFont(Fonts.sm)
        love.graphics.printf("Angle: " .. tostring(math.deg(p.r)), love.graphics.getWidth() / 2, 64, 250, "center")
    end
end

return state

