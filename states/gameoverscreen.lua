local state = {}

function state:enter() end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.md)
    love.graphics.printf("< Press SPACE to play again or ESC to go to the main menu>", 0, H / 2, W,'center')
end

function state:update(dt) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(GameScreen, 1) end
    if key == 'escape' then Gamestate.push(TitleScreen, 1) end
end

return state
