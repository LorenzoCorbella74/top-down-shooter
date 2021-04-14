local TimeManagement = {}

TimeManagement.new = function ()

    local self = {}
    self.time_dilatation = 1

    self.stepCounter = 0

    local isActive = false

    function self.setDilatation(fraction, forHowManySec)
        if not isActive then
            self.time_dilatation = fraction
            isActive = true
            -- back to normal
            Timer.after(forHowManySec, function()
                self.time_dilatation = 1
                isActive = false
            end)
        end
    end

    function self.processTime(dt)
        return dt * self.time_dilatation
    end

    function self.setCounter()
        self.stepCounter =  self.stepCounter + 1
        if self.stepCounter>60 then
            self.stepCounter = 1
        end
    end

    -- thanks to bot.number the calculation for 
    -- bots are spread to different frames
    function self.runEveryNumFrame(number, bot, callback)
        if self.stepCounter % (number + bot.number) == 0 then
            callback()
        end
    end

    function self.runAtFrameNum(num, callback)
        if self.stepCounter==num then
            callback()
        end
    end

    return self
    
end


return TimeManagement