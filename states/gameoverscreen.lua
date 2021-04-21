local config = require "config"

local state = {winner= nil}

function state:enter() 

    Timer.clear() -- Remove all timed and periodic functions. Functions that have not yet been executed will discarded

    for index, actor in ipairs(handlers.actors) do
        -- go to gamGameoverScreen state if player won
        if config.GAME.MATCH_TYPE=='deathmatch' and actor.kills == config.GAME.SCORE_TO_WIN then
            if actor.name=='player' then
                Sound:play("YouWin", 'announcer')
                state.winner = true
            else
                Sound:play("YouLost", 'announcer')
                state.winner = false
            end
            return
        end
        -- go to gamGameoverScreen state if team won
        if config.GAME.MATCH_TYPE~='deathmatch' and actor.teamStatus[actor.team].score == config.GAME.SCORE_TO_WIN then
            if actor.name=='player' then
                state.winner = true
                Sound:play("YouWin", 'announcer')
            else
                state.winner = false
                Sound:play("YouLost", 'announcer')
            end
            return
        end
    end

    -- if not reach the goals wins who was better...
    if config.GAME.MATCH_TYPE=='deathmatch' then
        table.sort(handlers.actors, function(a, b)
            return a.kills > b.kills
        end)
        if handlers.actors[1].name=='player' then
            state.winner = true
            Sound:play("YouWin", 'announcer')
        else
            state.winner = false
            Sound:play("YouLost", 'announcer')
        end
    else
        table.sort(handlers.actors, function(a, b)
            return a.teamStatus[a.team].score > b.teamStatus[a.team].score
        end)
        if handlers.actors[1].team=='blue' then
            state.winner = true
            Sound:play("YouWin", 'announcer')
        else
            state.winner = false
            Sound:play("YouLost", 'announcer')
        end
    end

end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.lg)
    love.graphics.printf(state.winner and"YOU WON THE MATCH" or "YOU HAVE LOST THE MATCH", 0, H /3, W,'center')
    love.graphics.setFont(Fonts.md)
    love.graphics.printf("< Press SPACE to play again or ESC to go to the main menu>", 0, H / 2, W,'center')
end

function state:update(dt) end

function state:keyreleased(key, code)
    if key == 'space' then Gamestate.push(GameScreen, 1) end
    if key == 'escape' then Gamestate.push(TitleScreen, 1) end
end

return state
