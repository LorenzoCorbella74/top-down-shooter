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

-- check if target is in cone of view of self
helpers.isInConeOfView = function(self, target)
    local angle = helpers.angle(self, target) -- angle with target
    local distance = helpers.dist(self, target)
    local delta = math.rad(60) -- angle extent
    local vision_length = 400 -- distance with target
    if self.r > 6.28 then self.r = self.r - 6.28 end
    local difference
    if math.abs(angle - self.r) > math.rad(180) then
        difference = 6.2832 - math.abs(angle - self.r)
    else
        difference = angle - self.r
    end
    -- print(math.deg(angle), math.deg(self.r),  math.deg(difference))

    if distance < vision_length and math.abs(difference) < delta then
        return true
    else
        return false
    end
end

-- if there is an obstacle hiding the entity from sight (using bump)
helpers.canBeSeen = function(point_sight, entity)
    local items, len = world:querySegment(point_sight.x, point_sight.y,entity.x, entity.y)
    for i = 1, len, 1 do
        local what = items[i]
        if what.layer and what.layer.name == 'walls' then
            -- print('type '.. tostring(items[i].layer.name))
            return false
        end
    end
    return true
end

-- move an entity according to an angle and a passed velocity
helpers.move = function(self, velocity)
    self.x = self.x + math.cos(self.r) * velocity;
    self.y = self.y + math.sin(self.r) * velocity;
    return self;
end

helpers.checkCollision = function(p, futurex, futurey)
    local cols, cols_len
    -- update the actor associated bounding box in the world
    p.x, p.y, cols, cols_len = world:move(p, futurex, futurey)

    --[[ collisions ]]
    for i = 1, cols_len do
        local item = cols[i].other
        local col = cols[i]
        if (item.type == 'powerups' and item.visible) then
            handlers.powerups.applyPowerup(item, p)
            -- test time dilatation
            handlers.timeManagement.setDilatation(0.5, 1)
        end
        if (item.type == 'ammo' and item.visible) then
            handlers.powerups.applyAmmo(item, p)
        end
        if (item.type == 'weapons' and item.visible) then
            handlers.powerups.applyWeapon(item, p)
        end
        print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x, col.normal.y))
    end

end

return helpers
