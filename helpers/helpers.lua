local helpers = {}

-- calculate the minor angle
helpers.shortestArc = function(a, b)
    if math.abs(b - a) < math.pi then return b - a end
    if b > a then return b - a - math.pi * 2 end
    return b - a + math.pi * 2
end

-- calculate the angle between two entities
helpers.angle = function(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    return math.atan2(dy, dx)
end

-- calculate the distance between two entities
helpers.dist = function(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    return math.sqrt(dx * dx + dy * dy);
end

-- point an entity toward an actor
helpers.pointTo = function(self, actor) self.r = helpers.angle(self, actor) end

-- turn progressively an entity to an actor
helpers.turnProgressivelyTo = function(self, actor)
    local angle = helpers.angle(self, actor)
    self.r = self.r + helpers.shortestArc(self.r, angle) * 0.2 -- percentage of rotation;
    return self
end

helpers.isInConeOfView = function(self, actor)
    local angle = helpers.angle(self, actor)
    local distance = helpers.dist(self, actor)
    local delta = math.rad(60)
    local vision_length = 300
    print(math.deg(angle), math.deg(self.r), math.deg(self.r -delta), math.deg(self.r + delta))
    
    if (distance < vision_length and math.abs(self.r - delta) < math.abs(angle) and--[[ and angle < self.r) or
        (distance < vision_length and self.r < angle and ]] math.abs(angle) < math.abs(self.r + delta)) then
        return true
    else
        return false
    end
end

-- -49.137190501824        172.32389986253 112.32389986253 232.32389986253  diretto ad est
-- -137.58957334894        270     210     330                              diretto a nord

-- move an entity according to an angle and a passed velocity
helpers.move = function(self, velocity)
    self.x = self.x + math.cos(self.r) * velocity;
    self.y = self.y + math.sin(self.r) * velocity;
    return self;
end

return helpers
