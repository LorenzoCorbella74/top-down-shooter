local C = {}

C.GAME = {
    BOTS_NUMBERS = 1,
    BOTS_VISION_LENGTH= 500,
    BOTS_PREDICTION_SKILL= 1,   -- can be from 0 to 1  // 5 difficulties 0, .25 .5 .75 1
    MATCH_DURATION = 120,
    RESPAWN_TIME = 10,
    GAMETYPE = 'deathmatch'
}

return C
