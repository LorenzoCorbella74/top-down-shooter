-- LIBRARIES
local Gamestate = require 'libs.gamestate' -- https://hump.readthedocs.io/en/latest/gamestate.html
local sti = require "libs.sti" -- https://github.com/karai17/Simple-Tiled-Implementation
local bump = require 'libs.bump' -- https://github.com/kikito/bump.lua
local Camera = require 'libs.camera' -- https://github.com/a327ex/STALKER-X

local state = {}

local pausescreen = require 'states.pausescreen'

-- called only once
function state:init()

    camera = Camera()
    camera:setFollowStyle('TOPDOWN')
    --[[ camera:setFollowLerp(0.2)
    camera:setFollowLead(10) ]]

    love.graphics.setFont(font_md)

    map = sti("maps/dm1.lua", {'bump'}) -- Load map file
    world = bump.newWorld(32) -- defining the world for collisions
    map:bump_init(world) -- start the phisics engine in the map

    require "entities.player" -- loading player
    require "entities.powerups" -- loading powerups

    map:removeLayer("Spawn_points") -- Remove unneeded object layer from map
end

function state:update(dt)
    local player = map.layers["Sprites"].player

    map:update(dt) -- Update world
    camera:update(dt)
    camera:follow(player.x, player.y)
end

function state:draw()
    camera:attach()

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
    -- Draw your game here
    camera:detach()
    camera:draw()
    drawHUD()
end

function state:keyreleased(key, code)
    if key == 'p' then Gamestate.push(pausescreen, 1) end
    if key == 'escape' then Gamestate.pop(1) end
    if key == 'e' then camera:shake(8, 1, 60) end               -- NOT working
    if key == 'f' then camera:flash(0.05, {0, 0, 0, 1}) end     -- working
end

function drawHUD()
    local hp = map.layers["Sprites"].player.hp
    local fps = love.timer.getFPS()
    love.graphics.print("HP: " .. tostring(hp), 32, 32)
    love.graphics.print("FPS: " .. tostring(fps), love.graphics.getWidth() - 96,
                        32)
end

return state

