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

-- point an entity toward an actor
helpers.pointTo = function(self, actor)
        self.angle = helpers.angle(self, actor)
end

-- turn progressively an entity to an actor
helpers.turnProgressivelyTo = function(self, actor)
    local angle = helpers.angle(self, actor)
    self.angle = self.angle + helpers.shortestArc(self.angle, angle) * 0.1 -- percentage of rotation;
    return self
end

-- move an entity according to an angle and a passed velocity
helpers.move = function(self, velocity)
    self.x = self.x + math.cos(self.angle) * velocity;
    self.y = self.y + math.sin(self.angle) * velocity;
    return self;
end

return helpers