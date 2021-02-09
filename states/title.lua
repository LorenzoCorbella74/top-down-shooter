local Gamestate = require 'libs.gamestate'
local gamescreen = require 'states.gamescreen'

local state = {}
local font = love.graphics.newFont('assets/fonts/shattered-v1.ttf', 24)
local elapsed = 0
local BLINK_INTERVAL = 25

function state:enter() love.graphics.setFont(font) end

function state:draw()
    love.graphics.print("Test 2D", love.graphics.getWidth() / 2 - 128,
                        love.graphics.getHeight() / 2)
    if elapsed % 100 > BLINK_INTERVAL then
        love.graphics.print("< Press SPACE to continue >", love.graphics.getWidth() / 2 -256,
        love.graphics.getHeight() / 2 +160)
    end
end

function state:update(dt) elapsed = elapsed + math.floor(dt * 100) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(gamescreen, 1) end
    if key == 'escape' then love.event.quit() end
end

return state
