
-- source: https://stackoverflow.com/a/1283608
function tableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

local config = {}

-- defaults
local deafults= {
    BOTS_NUMBERS = 0,
    BOTS_SKILL = 0,
    MATCH_DURATION = 300,
    SCORE_TO_WIN = 10,
    MAP = 1,
    MATCH_TYPE = 'deathmatch',    -- can be 'deathmatch', 'team_deathmatch', "ctf"
    
    RESPAWN_TIME = 10,
    ACTORS_SPEED = 240,           -- pixels per second -> TODO: slider for game actor speed (game speed)
    WAYPOINTS_TIMING = 12         -- bots can not choose the same item but wait 
}

config.setGame = function (input)
    config.GAME = tableMerge(deafults, input)
end
return config

-- maps info; https://quake.fandom.com/wiki/Quake_III_Arena

