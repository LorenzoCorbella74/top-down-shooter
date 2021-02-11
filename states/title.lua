--[[ local Gamestate = require 'libs.gamestate' ]]

local state = {}

local elapsed = 0
local BLINK_INTERVAL = 25

function state:enter() end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(font_lg) 
    love.graphics.printf("Test 2D", 0, H / 3, W, 'center')
    if elapsed % 100 > BLINK_INTERVAL then
        love.graphics.setFont(font_md) 
        love.graphics.printf("< Press SPACE to play or ESC to exit>", 0,H / 2, W, 'center')
    end
end

function state:update(dt) elapsed = elapsed + math.floor(dt * 100) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(gamescreen, 1) end
    if key == 'escape' then love.event.quit() end
end

return state