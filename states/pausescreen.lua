local state = {}

function state:enter(from)
    self.from = from -- record previous state
end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    -- draw previous screen
    self.from:draw()
    -- overlay with pause message
    love.graphics.setColor(0.2, 0.2, 0.2, 0.35)
    love.graphics.rectangle('fill', 0, 0, W, H)
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('Game has been paused...', 0, H / 4, W, 'center')
    love.graphics.printf('Press ESC or p to come back to game', 0, H / 4+64, W, 'center')
    
    table.sort(handlers.actors, function(a, b) return a.kills > b.kills end)
    love.graphics.printf('Name'..' '.. 'Kills' .. ' '.. 'Deaths', 0, H / 4+100, W, 'center')
    for i = 1, #handlers.actors, 1 do
        local e = handlers.actors[i]
        love.graphics.printf(e.name ..' '.. e.kills .. ' '.. e.numberOfDeaths, 0, H / 4+100 +32*i, W, 'center') 
        end
    end

function state:update(dt) end

function state:keyreleased(key, code)
    if key == 'p' then Gamestate.pop() end
    if key == 'escape' then Gamestate.pop() end
end

return state
