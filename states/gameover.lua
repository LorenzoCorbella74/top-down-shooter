--[[ local Gamestate = require 'libs.gamestate'
-- local gamescreen = require 'states.gamescreen'
-- local title = require 'states.title' ]]

local state = {}

function state:enter() end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(font_md)
    love.graphics.printf("< Press SPACE to play again or ESC to go to the main menu>", 0, H / 2, W,
                         'center')
end

function state:update(dt) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(gamescreen, 1) end
    if key == 'escape' then Gamestate.push(title, 1) end
end

return state
