local state = {}

local elapsed = 0
local BLINK_INTERVAL = 25

-- main game menu
local buttons = {}
function addBtn(label, fn) return {label = label, fn = fn, last = nil, now = nil} end
table.insert(buttons, addBtn('Start', function() Gamestate.push(InputScreen, 1)  end))
table.insert(buttons, addBtn('Settings', function() print('Settings') end))
table.insert(buttons, addBtn('Exit', function() love.event.quit() end))


function state:enter()
    -- background music
    Sound:play('backgroundTitle', 'background_music', 1, 1, true)
    -- set mouse visibility
    love.mouse.setVisible(true)
end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    
    love.graphics.setFont(Fonts.lg)
    love.graphics.setColor(1, 0.4, 0.5, 0.25)
    if elapsed % 100 > BLINK_INTERVAL then
        love.graphics.printf("2D ARENA", 0, H / 5, W, 'center')
    end
    love.graphics.print('Ver: 0.0.8', Fonts.sm, W - 90, H - 50)

    local button_width = W / 5
    local button_height = 80
    local margin = 16
    local cursor_y = 0
    local total_height = (button_height + margin) * #buttons
    love.graphics.setFont(Fonts.md)

    for index, value in ipairs(buttons) do
        value.last = value.now
        local bx = (W * 0.5) - (button_width * 0.5)
        local by = (H * 0.65) - (button_height * 0.5) - (total_height * 0.5) + cursor_y
        local color = {1, 0.4, 0.5, 0.25}
        local mx, my = love.mouse.getPosition()
        local over = mx > bx and mx < bx + button_width and my > by and my< by + button_height
        if over then
            color = {1, 0, 0, 0.75}
        end
        value.now = love.mouse.isDown(1)
        if value.now and not value.last and over then
            value.fn()
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle('fill', bx, by, button_width, button_height)
        love.graphics.setColor(0, 0, 0, 1)
        local textW = Fonts.md:getWidth(value.label)
        local textH = Fonts.md:getHeight(value.label)
        love.graphics.print(value.label, Fonts.md, (W * 0.5) - textW * 0.5, by + textH)
        cursor_y = cursor_y + (button_height + margin)
    end
end

function state:update(dt) elapsed = elapsed + math.floor(dt * 100) end

function state:keyreleased(key, code)
    -- if key == 'space' then Gamestate.push(InputScreen, 1) end
    -- if key == 'escape' then love.event.quit() end
end

-- works only for Gamestate.switch
function state:leave()
    print('Leaving Title screen')
    Sound:stop('background_music')
end

return state
