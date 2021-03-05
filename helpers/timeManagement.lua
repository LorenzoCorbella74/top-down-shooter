local TimeManagement = {}

TimeManagement.new = function ()

    local self = {}
    self.time_dilatation = 1

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

    return self
    
end


return TimeManagement