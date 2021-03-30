local C = {}

C.GAME = {
    BOTS_NUMBERS = 1,
    MATCH_DURATION = 120,
    RESPAWN_TIME = 10,
    GAMETYPE = 'deathmatch',     -- can be 'deathmatch', 'team_deathmatch', "ctf"

    BOTS_VISION_LENGTH= 500,
    BOTS_VISION_ANGLE= 35,
    BOTS_PREDICTION_SKILL= .25,   -- can be from 0 to 1  // 5 difficulties 0, .25 .5 .75 1
}

return C
