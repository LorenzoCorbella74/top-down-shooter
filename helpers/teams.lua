local teams = {
    team1 = {
        score = 0,
        enemyFlagStatus = 'base', -- base, taken, dropped
        name= 'team1',
        enemyFlag = nil,          -- reference to the obj
        carrier= nil              -- reference to the actor taking it
    },
    team2 = {
        score = 0,
        enemyFlagStatus = 'base',
        name= 'team2',
        enemyFlag = nil,
        carrier= nil
    }
}

return teams