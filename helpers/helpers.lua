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

helpers.correctAngle = function(angle)
    return angle < 0 and math.rad(360) + angle or angle -- angle correction if negative
end

helpers.isInConeOfView = function(self, target)
    local angle = helpers.correctAngle(helpers.angle(self, target)) -- angle between entities
    local distance = helpers.dist(self, target)
    local delta = math.rad(60) -- angle extent
    local corrected = helpers.correctAngle(self.r)
    local vision_length = 400 -- distance with target

    print(math.deg(angle), math.deg(corrected))

    if distance < vision_length and (corrected - angle <delta) then
        return true
    else
        return false
    end
end

-- if there is an obstacle hiding the entity from sight
helpers.canBeSeen = function(point_sight, entity)
    local items, len = world:querySegment(point_sight.x, point_sight.y,
                                          entity.x, entity.y)
    -- print(#items)
    if len == 1 then
        for i = 1, len do
    
            local col = items[i]
            local item = items[i].other
            -- impact with walls
    
        end
    end
    return len == 0
end

-- move an entity according to an angle and a passed velocity
helpers.move = function(self, velocity)
    self.x = self.x + math.cos(self.r) * velocity;
    self.y = self.y + math.sin(self.r) * velocity;
    return self;
end

return helpers
