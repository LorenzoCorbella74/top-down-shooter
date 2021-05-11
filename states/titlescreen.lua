local state = {}

local elapsed = 0
local BLINK_INTERVAL = 25

function state:enter()
    -- background music
    Sound:play('backgroundTitle', 'background_music', 1,1, true)
end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.lg) 
    love.graphics.printf("2D ARENA", 0, H / 3, W, 'center')
    if elapsed % 100 > BLINK_INTERVAL then
        love.graphics.setFont(Fonts.md) 
        love.graphics.printf("< Press SPACE to play or ESC to exit >", 0,H / 2, W, 'center')
    end
end

function state:update(dt) elapsed = elapsed + math.floor(dt * 100) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(InputScreen, 1) end
    if key == 'escape' then love.event.quit() end
end

-- works only for Gamestate.switch
function state:leave()
    print('Leaving Title screen')
    Sound:stop('background_music')
end


return state
