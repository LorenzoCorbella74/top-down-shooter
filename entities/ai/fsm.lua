local collect = require "entities.ai.collect_state"
local collectctf = require "entities.ai.collect_state_ctf"
local collectTeam = require "entities.ai.collect_state_team"
local fight = require "entities.ai.fight_state"
local config = require "config"

local FsmMachine = {}

function FsmMachine.new(bot)
    local self = {}
    self.states = {} -- table of states
    self.curState = {stateName=nil} -- current state
    self.stack = {} -- stack of states' names
    self.bot = bot

    function self.init()
        -- register all states
        self.registerState(collect)
        self.registerState(collectctf)
        self.registerState(collectTeam)
        self.registerState(fight)

        -- default initialization (collect)
        if config.GAME.MATCH_TYPE == 'ctf' then
            self.push(collectctf.stateName)
        elseif config.GAME.MATCH_TYPE == 'team_deathmatch' then
            self.push(collectTeam.stateName)
        else
            self.push(collect.stateName)
        end
    end

    -- register state
    function self.registerState(baseState)
        self.states[baseState.stateName] = baseState
    end

    -- updating the current status
    function self.update(dt) 
        self.curState.OnUpdate(dt, self.bot)
     end

    -- put an item on the stack
    function self.push(stateName)
        self.stack[#self.stack + 1] = stateName
        self.switch(stateName)
    end

    function self.pop()
        -- make sure there's something to pop off the stack
        if #self.stack > 0 then
            -- remove item (pop) from stack
            table.remove(self.stack, #self.stack)
            self.switch(self.stack[#self.stack])
        end
    end

    -- switching state (use internally)
    function self.switch(stateName)
        if self.curState.stateName ~= stateName then
            if self.curState and self.curState.OnLeave then
                self.curState.OnLeave(self.bot)
            end
            self.curState = self.states[stateName]
            if self.curState and self.curState.OnEnter then
                self.curState.OnEnter(self.bot)
            end
        end
    end

    return self

end

return FsmMachine

