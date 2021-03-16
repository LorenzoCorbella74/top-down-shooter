local helpers = require "../../helpers.helpers"

local collectAndfight = {stateName = 'collectAndfight'}

function collectAndfight.OnEnter(bot)
    print("collectAndfight.OnEnter() " .. bot.name)
    -- find best target of movement (collectAndfightable or waypoint)
    -- calculate path
end

function collectAndfight.OnUpdate(dt, bot)

    
end

function collectAndfight.OnLeave(bot)
    print("collectAndfight.OnLeave() " .. bot.name)
    -- remove something
end

return collectAndfight
