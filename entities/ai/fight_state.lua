local fight = {stateName = 'fight'}

function fight.OnEnter(bot) print("fight.OnEnter() " .. bot.name) end

function fight.OnUpdate(dt, bot) end

function fight.OnLeave(bot) print("fight.OnLeave() " .. bot.name) end

return fight
