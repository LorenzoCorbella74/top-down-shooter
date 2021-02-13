require "entities.player" -- loading player
require "entities.powerups" -- loading powerups
require "entities.bullets" -- Loading bullets

local countdown = require "..helpers.countdown"

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
    -- Timer.after(60, function() Gamestate.push(gameover) end)
    GameCountdown = countdown.new(120)
end

function state:update(dt)
    map:update(dt) -- Update all map layers internally
    camera:update(dt)
    camera:follow(currentCameraTarget.x, currentCameraTarget.y)
    Timer.update(dt)
    GameCountdown.update(dt)
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
    drawCursor()
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

-- TODO 
function state:mousepressed(x, y, button, istouch, presses)

    if button == 1 then
        local p = map.layers["Sprites"].player
        local sx = (p.x + p.w / 2)
        local sy = (p.y + p.h / 2)

        -- Gets the position of the mouse in world coordinates 
        -- equivals to camera:toWorldCoords(love.mouse.getPosition())
        local mx, my = camera:getMousePosition() 
        
        local angle = math.atan2(my - p.y, mx - p.x)

        -- todo guardare segni del cos/sen
        BH.create({
            x = p.x + 64*math.cos(angle),
            y = p.y + 64*math.sin(angle)
        }, angle, 'machinegun')
    end
end

function drawHUD()
    love.graphics.setFont(font_md)
    local p = map.layers["Sprites"].player
    local fps = love.timer.getFPS()
    love.graphics.print("HP:" .. tostring(p.hp), 32, 32)
    love.graphics.print("AP:" .. tostring(p.ap), 110, 32)
    love.graphics.print("Kills:" .. tostring(p.kills), 170, 32)
    love.graphics.print("FPS:" .. tostring(fps), love.graphics.getWidth() - 96,32)
    love.graphics.printf("Time: " .. tostring(GameCountdown.show()), love.graphics.getWidth()/2, 32, 200, "center")
    love.graphics.printf("Angle: " .. tostring(p.r), love.graphics.getWidth()/2, 64, 250, "center")

end

--  cursor
function drawCursor()
    love.graphics.line(love.mouse.getX(), love.mouse.getY() - 16,
                       love.mouse.getX(), love.mouse.getY() + 16)
    love.graphics.line(love.mouse.getX() - 16, love.mouse.getY(),
                       love.mouse.getX() + 16, love.mouse.getY())
end

return state

