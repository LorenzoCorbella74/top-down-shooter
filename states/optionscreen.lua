local state = {}

function state:enter(from)
    self.from = from -- record previous state
end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    -- draw previous screen
    self.from:draw()
    -- overlay with pause message
    love.graphics.setColor(1, 0.2, 0.75, 0.65)
    love.graphics.rectangle('fill', 0, 0, W, H)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Option screen', 0, H / 4, W, 'center')
    love.graphics.printf('Press "x" to end the game', 0, H / 3, W, 'center')
end

function state:update(dt) end

function state:keyreleased(key, code)
    if key == 'x' then Gamestate.push(TitleScreen, 1) end
    if key == 'escape' then Gamestate.pop() end
end

return state