local collect = require "entities.ai.collect_state"
local fight = require "entities.ai.fight_state"
local collectAndfight = require "entities.ai.collect_and_fight_state"

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
        self.registerState(collectAndfight)
        self.registerState(fight)

        -- default initialization (collect)
        self.push(collect.stateName)
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
            if self.curState.OnLeave then
                self.curState.OnLeave(self.bot)
            end
            self.curState = self.states[stateName]
            if self.curState.OnEnter then
                self.curState.OnEnter(self.bot)
            end
        end
    end

    return self

end

return FsmMachine

