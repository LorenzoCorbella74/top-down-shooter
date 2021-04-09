local PointsHandler = require "entities.points" -- handler for spawnPoints, waypoints
local PlayerHandler = require "entities.player" -- handler for player
local PowerupsHandler = require "entities.powerups" -- handler for powerups
local BulletsHandler = require "entities.bullets" -- handler for bullets
local BotsHandler = require "entities.bots" -- handler for bots
local countdown = require "..helpers.countdown" -- handler for game countdown
local config = require "config"

local PathfindHandler = require "..helpers.pathfinding" -- handler for jupiter wrapper
local TimeManagement = require "..helpers.timeManagement" -- handle time effect (ala Max payne...)

local state = {lastChangeWeaponTime = 0, currentCameraTarget = {}, message = ''}

-- init is called only once
-- enter is called when push
-- restore is called when pop
function state:enter()

    camera = Camera()
    camera:setFollowStyle('TOPDOWN')

    love.mouse.setVisible(false)
    camera:setFollowLerp(0.2)
    camera:setFollowLead(10)

    map = sti("maps/dm1.lua", {'bump'}) -- Load map file
    world = bump.newWorld(32) -- defining the world for collisions
    map:bump_init(world)

    handlers = {}

    -- spawn_points and bots waypoints
    handlers.points = PointsHandler.new()
    handlers.points.getPointsFromMap()

    -- path finding helpers for jumper
    local map_for_jumper = require('maps/dm' .. tostring(1))
    handlers.pf = PathfindHandler.new(map_for_jumper, 'walls', 0, 'JPS')

    -- player
    handlers.player = PlayerHandler.new()
    handlers.player.create()

    -- powerups
    handlers.powerups = PowerupsHandler.new()
    handlers.powerups.init()

    -- Bullets
    handlers.bullets = BulletsHandler.new()

    -- bots
    handlers.actors = {}
    table.insert(handlers.actors, handlers.player.player)
    handlers.bots = BotsHandler.new()
    for i = 1, config.GAME.BOTS_NUMBERS, 1 do
        handlers.bots.create(i, 0 --[[ math.random(1, 5) ]]) -- bot skill levels
        table.insert(handlers.actors, handlers.bots.bots[i])
    end
    -- seed waypoints with each bot information
    handlers.points.seedBotsInWaypoints(handlers.actors)
    -- seed waypoints with each bot information
    handlers.powerups.seedBotsInPowerups(handlers.actors)
    for i = 1, config.GAME.BOTS_NUMBERS, 1 do
        handlers.bots.bots[i].brain.init() -- wamder as default
    end

    -- Remove unneeded object layer from map
    map:removeLayer("Spawn_points")
    map:removeLayer("powerups")
    map:removeLayer("waypoints")

    -- default camera is following the player
    handlers.camera = {}
    handlers.camera.setCameraOnActor = function(actor)
        state.currentCameraTarget = actor
    end
    handlers.camera.setCameraOnActor(handlers.player.player)

    -- set game message
    handlers.ui = {}
    handlers.ui.setMsg = function(msg) state.message = msg end

    -- after the matchDuration go to game over screen
    GameCountdown = countdown.new(config.GAME.MATCH_DURATION)
    -- bullet time management
    handlers.timeManagement = TimeManagement.new()
end

function state:update(dt)
    dt = handlers.timeManagement.processTime(dt)
    handlers.timeManagement.setCounter()

    map:update(dt) -- Update internally all map layers

    -- player firing !!!
    if love.mouse.isDown(1) then handlers.player.fire(dt) end
    camera:update(dt)
    camera:follow(state.currentCameraTarget.x, state.currentCameraTarget.y)
    Timer.update(dt)
    GameCountdown.update(dt)

    for index, actor in ipairs(handlers.actors) do
        if actor.kills == config.GAME.SCORE_TO_WIN or actor.teamStatus[actor.team].score == config.GAME.SCORE_TO_WIN then
            Gamestate.push(GameoverScreen) -- go to gamGameoverScreen state
            return
        end
    end
end

function state:draw()
    camera:attach()

    -- Draw your game here
    local scale = 1
    -- Scale world with camera.scale

    if debug then
        camera.draw_deadzone = true
    else
        camera.draw_deadzone = false
    end

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
    local p = map.layers["Sprites"].player
    if key == 'p' then Gamestate.push(PauseScreen, 1) end
    if key == 'escape' then Gamestate.pop(1) end
    if key == 'e' then camera:shake(8, 1, 60) end --  working BUT NOT PERFECT !!!
    if key == 'f' then camera:flash(0.15, {1, 0, 0, 0.25}) end -- working
    if key == 'l' then
        local filename = string.format("screenshot-%d.png", os.time())
        love.graphics.captureScreenshot(filename)
        print(string.format("written %s", filename))
    end -- not working
    if key == 'i' then
        debug = not debug
        p.invisible = not p.invisible
    end
    if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
        local key = tonumber(key)
        local w = p.weaponsInventory.weapons[key]
        -- weapon is set as current weapons if available
        if w.available and w.shotNumber > 0 then
            p.weaponsInventory.selectedWeapon = w
        end
    end
    -- in debug cycle among bots
    if debug and key =='c' then
        for index, actor in ipairs(handlers.actors) do
            if actor == state.currentCameraTarget  and index < #handlers.actors then
                handlers.camera.setCameraOnActor(handlers.actors[index + 1])
                break
            elseif actor == state.currentCameraTarget  and index == #handlers.actors then
                handlers.camera.setCameraOnActor(handlers.actors[1])
                break
            end
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

function drawHUD()
    love.graphics.setFont(Fonts.md)
    local p = map.layers["Sprites"].player
    local w = p.weaponsInventory.selectedWeapon
    -- Player data
    love.graphics.print("HP:" .. tostring(p.hp),  48, love.graphics.getHeight()-64)
    love.graphics.print("AP:" .. tostring(p.ap),  48, love.graphics.getHeight()-32)
    love.graphics.print("Score: " .. tostring(p.kills), 192, 32)
    love.graphics.print("Team: " .. tostring(p.teamStatus['team1'].score) ..'-'..tostring(p.teamStatus['team2'].score), 192, 64)
    -- current weapon and available shoots
    love.graphics.print(w.name .. ':' .. w.shotNumber, love.graphics.getWidth()-120, love.graphics.getHeight()-64)
    -- FPS
    local fps = love.timer.getFPS()
    love.graphics.print("FPS:" .. tostring(fps), love.graphics.getWidth() - 100, 16)
    -- Time of the current match
    love.graphics.printf("Time: " .. tostring(GameCountdown.show()), (love.graphics.getWidth() / 2) - 64, 32, 200, "center")
    -- game message
    love.graphics.printf(state.message, (love.graphics.getWidth() / 2) - 128, 64, 220, "center")
end

return state

