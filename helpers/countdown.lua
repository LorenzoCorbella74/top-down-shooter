-- source: https://stackoverflow.com/a/36817464

local countdown = {}

countdown.new = function(time)

    local self = {}

    local start = true -- flags that you want the countdown to start
    local stopTime = 0 -- used to hold the stop time
    local stop = false -- flag to indicate that stop time has been reached
    local counter = 0

    -- public
    local stopIn = time or (60 * 5) -- how long the timer should run
    self.timeTillStop = 0           --  holds the display time
    self.status = nil               -- holds the status msg if the countdown

    -- public fn
    function self.update(dt)
        counter = counter + dt
        if start == true then
            stopTime = dt + stopIn -- yes the set the stoptime
            start = false -- clear the start flag
        else -- waiting for stop
            if counter >= stopTime then -- has stop time been reached?
                stop = true -- yes the flag to stop
            end
        end

        self.timeTillStop = stopTime - counter -- for display of time till stop

        if self.timeTillStop <= 120 and not self.status then
            Sound:play("TwoMinuteWarning", 'announcer')
            self.status= 'Two minutes left'
            handlers.ui.setMsg(self.status)
            camera:shake(8, 1, 60)
            Timer.after(2.5, function() handlers.ui.setMsg('') end)
        end
        if self.timeTillStop <= 60 and self.status== 'Two minutes left' then
            Sound:play("OneMinuteWarning", 'announcer')
            self.status= 'One minutes left'
            camera:shake(8, 1, 60)
            Timer.after(2.5, function() handlers.ui.setMsg('') end)
        end

        if stop == true then
            Gamestate.push(GameoverScreen) -- go to gamGameoverScreen state
        end
    end

    function self.show()
        local minutes = math.floor(self.timeTillStop / 60);
        local seconds = math.floor(self.timeTillStop % 60);
        minutes = minutes < 10 and "0" .. tostring(minutes) or tostring(minutes)
        seconds = seconds < 10 and "0" .. tostring(seconds) or tostring(seconds)
        return minutes .. ":" .. seconds
    end

    return self
end

return countdown
