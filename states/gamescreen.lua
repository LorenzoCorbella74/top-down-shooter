require "entities.player" -- loading player
require "entities.powerups" -- loading powerups
require "entities.bullets" -- Loading bullets

local state = {}

-- init is called only once
-- enter is called when push
-- restore is called when pop
function state:enter()

    camera = Camera()
    camera:setFollowStyle('TOPDOWN')
    --[[ camera:setFollowLerp(0.2)
    camera:setFollowLead(10) ]]

    map = sti("maps/dm1.lua", {'bump'}) -- Load map file
    world = bump.newWorld(32) -- defining the world for collisions
    map:bump_init(world) -- start the phisics engine in the map

    createPlayer()
    createPowerUps()
    BH = createBulletHandler()

    map:removeLayer("Spawn_points") -- Remove unneeded object layer from map

    currentCameraTarget = map.layers["Sprites"].player

    -- after the matchDuration go to game over screen 
    Timer.after(60, function() Gamestate.push(gameover) end)
end

function state:update(dt)
    map:update(dt) -- Update all map layers
    camera:update(dt)
    camera:follow(currentCameraTarget.x, currentCameraTarget.y)
    Timer.update(dt)
end

function state:draw()
    camera:attach()

    -- Draw your game here
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

    camera:detach()
    camera:draw()
    drawHUD()
end

function state:keyreleased(key, code)
    if key == 'p' then Gamestate.push(pausescreen, 1) end
    if key == 'escape' then Gamestate.pop(1) end
    if key == 'e' then camera:shake(8, 1, 60) end --  working BUT NOT PERFECT !!!
    if key == 'f' then camera:flash(0.05, {0, 0, 0, 1}) end -- working
end

--[[ function state:leave()
    map = nil
    world = nil
    camera = nil
    currentCameraTarget = nil
end ]]

function state:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local p = map.layers["Sprites"].player
        local sx = (p.x + p.w / 2)
        local sy = (p.y + p.h / 2)
        local angle = math.atan2(y - sy, x - sx)
        BH.create({x = lerp(p.x, x, .15), y = lerp(p.y, y, .15)}, angle,
                  'machinegun')
    end
end

function drawHUD()
    love.graphics.setFont(font_md)
    local p = map.layers["Sprites"].player
    local fps = love.timer.getFPS()
    love.graphics.print("HP:" .. tostring(p.hp), 32, 32)
    love.graphics.print("AP:" .. tostring(p.ap), 110, 32)
    love.graphics.print("Kills:" .. tostring(p.kills), 170, 32)
    love.graphics.print("FPS:" .. tostring(fps), love.graphics.getWidth() - 96,
                        32)
end

-- todo
function lerp(a, b, t) return a * (1 - t) + b * t end

return state

