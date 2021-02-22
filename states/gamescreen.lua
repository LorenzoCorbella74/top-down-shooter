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

    mousepressed = false

    love.mouse.setVisible(false)
    --[[ camera:setFollowLerp(0.2)
    camera:setFollowLead(10) ]]

    map = sti("maps/dm1.lua", {'bump'}) -- Load map file
    world = bump.newWorld(32) -- defining the world for collisions
    map:bump_init(world) -- start the phisics engine in the map

    handlers = {
        player = CreatePlayer(), -- by calling the map layers are created ...
        powerups = CreatePowerUps(),
        bullets = CreateBulletHandler()
    }

    map:removeLayer("Spawn_points") -- Remove unneeded object layer from map
    map:removeLayer("powerups") -- Remove unneeded object layer from map

    currentCameraTarget = map.layers["Sprites"].player

    -- after the matchDuration go to game over screen 
    GameCountdown = countdown.new(120)

end

function state:update(dt)
    -- if love.mouse.isDown(1) then fire() end TODO

    map:update(dt) -- Update internally all map layers
    camera:update(dt)
    camera:follow(currentCameraTarget.x, currentCameraTarget.y)
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
    if key == 'f' then camera:flash(0.015, {1, 0, 0, 1}) end -- working
    if key == 'i' then debug = not debug end
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
        fire()
    end
end

function state:mousereleased(x, y, button, istouch, presses)
    if button == 1 then mousepressed = true end
end

function fire()
    local p = map.layers["Sprites"].player

    if p.alive and p.weaponsInventory.selectedWeapon.shotNumber > 0 then
        -- Gets the position of the mouse in world coordinates 
        -- equivals to camera:toWorldCoords(love.mouse.getPosition())
        local mx, my = camera:getMousePosition()
        local angle = math.atan2(my - (p.y + p.h / 2), mx - (p.x + p.w / 2))

        local sign = angle < 0 and -1 or 1
        handlers.bullets.create({
            x = p.x + p.w / 2 + 32 * sign * math.cos(angle),
            y = p.y + p.h / 2 + 32 * sign * math.sin(angle)
        }, angle, p.weaponsInventory.selectedWeapon)
    else
        p.weaponsInventory.getBest()
    end
end

--[[ shoot(dt: number) {
    if (this.alive && this.currentWeapon.shotNumber>0) {
        let now = Date.now();
        if (now - this.attackCounter < this.currentWeapon.frequency) return;
        this.attackCounter = now;
        let vX = (this.control.mouseX - (this.x - this.camera.x));
        let vY = (this.control.mouseY - (this.y - this.camera.y));
        let dist = Math.sqrt(vX * vX + vY * vY);	// si calcola la distanza
        vX = vX / dist;								// si normalizza
        vY = vY / dist;
        for (let i = this.currentWeapon.count-1; i >= 0; i--) {
            this.bullet.create(this.x, this.y, vX, vY, 'player', this.index, this.damage, this.currentWeapon);  // 8 è la velocità del proiettile
            this.currentWeapon.shotNumber--;
        }
    }else{
        // da valutare se prevederlo in automatico
        this.weaponsInventory.getBest();
        this.currentWeapon = this.weaponsInventory.selectedWeapon;	// arma corrente
    }
} ]]

function drawHUD()
    love.graphics.setFont(Fonts.md)
    local p = map.layers["Sprites"].player
    local w = p.weaponsInventory.selectedWeapon
    -- Player data
    love.graphics.print("HP:" .. tostring(p.hp), 32, 32)
    love.graphics.print("AP:" .. tostring(p.ap), 128, 32)
    love.graphics.print("Kills:" .. tostring(p.kills), 192, 32)
    -- current weapon and available shoots
    love.graphics.print(w.name .. ':' .. w.shotNumber, 256, 32)
    -- FPS
    local fps = love.timer.getFPS()
    love.graphics.print("FPS:" .. tostring(fps), love.graphics.getWidth() - 96,
                        32)
    -- Time of the current match
    love.graphics.printf("Time: " .. tostring(GameCountdown.show()),
                         love.graphics.getWidth() / 2, 32, 200, "center")
    -- debug
    if debug then
        love.graphics.setFont(Fonts.sm)
        love.graphics.printf("Angle: " .. tostring(math.deg(p.r)),
                             love.graphics.getWidth() / 2, 64, 250, "center")
    end
end

return state

