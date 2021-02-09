-- Debug
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- LIBRARIES
local sti = require "libs.sti" -- Simple Tiled Implementation 
local bump = require 'libs.bump' -- bump
local Camera = require 'libs.camera'

function love.load()

    camera = Camera()
    camera:setFollowStyle('NO_DEADZONE')

    map = sti("maps/dm1.lua", {'bump'}) -- Load map file
    world = bump.newWorld(32) -- defining the world for collisions
    map:bump_init(world) -- start the phisics engine in the map

    require "entities.player" -- loading player
    require "entities.powerups" -- loading powerups

    map:removeLayer("Spawn_points") -- Remove unneeded object layer from map
end

function love.update(dt)
    local player = map.layers["Sprites"].player

    map:update(dt) -- Update world
    camera:update(dt)
    camera:follow(player.x, player.y)
end

function love.draw()

    local scale = 1 -- Scale world

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local mapMaxWidth = map.width * map.tilewidth
    local mapMaxHeight = map.height * map.tileheight
    local x = math.min(math.max(0, camera.x - windowWidth / 2),
                       mapMaxWidth - windowWidth)
    local y = math.min(math.max(0, camera.y - windowHeight / 2),
                       mapMaxHeight - windowHeight)

    map:draw(-x, -y, scale, scale)

    drawHUD()
end

function drawHUD()
    local hp = map.layers["Sprites"].player.hp
    local fps = love.timer.getFPS()
    love.graphics.print(hp, 32, 32)
    love.graphics.print("FPS: " .. tostring(fps), love.graphics.getWidth() - 60,10)
end

