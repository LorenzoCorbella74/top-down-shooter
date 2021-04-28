local config = {}

config.GAME = {
    BOTS_NUMBERS = 0,
    MATCH_DURATION = 300,
    SCORE_TO_WIN = 10,
    RESPAWN_TIME = 10,
    MATCH_TYPE = 'deathmatch',    -- can be 'deathmatch', 'team_deathmatch', "ctf"

    ACTORS_SPEED = 240,           -- pixels per second -> TODO: slider for game actor speed (game speed)

    WAYPOINTS_TIMING = 12         -- bots can not choose the same item but wait 
}

return config

-- maps info; https://quake.fandom.com/wiki/Quake_III_Arena

