local config = {}

config.GAME = {
    BOTS_NUMBERS = 3,
    MATCH_DURATION = 240,
    SCORE_TO_WIN = 15,
    RESPAWN_TIME = 10,
    MATCH_TYPE = 'team_deathmatch',           -- can be 'deathmatch', 'team_deathmatch', "ctf"

    ACTORS_SPEED = 240,           -- pixels per second -> TODO: slider for game actor speed (game speed)

    WAYPOINTS_TIMING = 12         -- bots can not choose the same item but wait 
}

return config

-- maps info; https://quake.fandom.com/wiki/Quake_III_Arena
