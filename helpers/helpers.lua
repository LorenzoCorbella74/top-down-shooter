-- map, filter, reduce
-- source: https://devforum.roblox.com/t/functional-shenanigans-map-filter-partition-reduce-two-ways/199027
local map = function(sequence, transformation)
    local newlist = {}
    for i, v in pairs(sequence) do newlist[i] = transformation(v) end
    return newlist
end

local filter = function(sequence, predicate)
    local newlist = {}
    if sequence then
        for i, v in ipairs(sequence) do
            if predicate(v) then table.insert(newlist, v) end
        end
    end
    return newlist
end

local partition = function(sequence, predicate)
    local left = {}
    local right = {}
    for i, v in ipairs(sequence) do
        if (predicate(v)) then
            table.insert(left, v)
        else
            table.insert(right, v)
        end
    end
    return left, right
end

local reduce = function(sequence, operator)
    if #sequence == 0 then return nil end
    local out = nil
    for i = 1, #sequence do out = operator(out, sequence[i]) end
    return out
end

-- source: https://stackoverflow.com/a/1283608
function tableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

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
    return math.sqrt(dx * dx + dy * dy), dx, dy;
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
    local items, len = world:querySegment(point_sight.x, point_sight.y, entity.x, entity.y)
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
    local movementfilter = function(item, other)
        if other.name == "waypoint" then
            return 'cross'
        elseif other.type == 'powerups' then
            return 'cross'
        elseif other.type == 'ammo' then
            return 'cross'
        elseif other.type == 'weapons' then
            return 'cross'
        else
            return 'slide'
        end
    end
    -- update the actor associated bounding box in the world
    p.x, p.y, cols, cols_len = world:move(p, futurex, futurey, movementfilter)

    --[[ collisions ]]
    for i = 1, cols_len do
        local item = cols[i].other
        local col = cols[i]
        if (item.type == 'powerups' and item.visible) then
            handlers.powerups.applyPowerup(item, p)
            -- test time dilatation
            -- sound!
            -- handlers.timeManagement.setDilatation(0.5, 1)
        end
        if (item.type == 'ammo' and item.visible) then
            handlers.powerups.applyAmmo(item, p)
        end
        if (item.type == 'weapons' and item.visible) then
            handlers.powerups.applyWeapon(item, p)
        end
        if (item.name == 'waypoint') then
            item.players[p.index].visible = false
            Timer.after(6, function()
                item.players[p.index].visible = true
            end)
        end

        -- fix a probable error in bump library to make bots able to cut the corners of walls
        if (p.name ~= 'player' and item.layer and item.layer.name == 'walls') then
            local t = 1
            local x = p.x
            local y = p.y
            local items1, len1 = world:queryPoint(x - t, y - t)
            local items2, len2 = world:queryPoint(x + p.w + t, y - t)
            local items3, len3 = world:queryPoint(x + p.w + t, y + p.h + t)
            local items4, len4 = world:queryPoint(x - t, y + p.h + t)
            print(tostring(len1), tostring(len2), tostring(len3), tostring(len4))
            -- 1  2
            -- 4  3

            -- 1
            if len1 ~= 0 and len2 == 0 and len3 == 0 and len4 == 0 and col.normal.x ==1 and col.normal.y == 0 then
                p.x = p.x - t*2
                p.y = p.y + t*2
            end
            if len1 ~= 0 and len2 == 0 and len3 == 0 and len4 == 0 and col.normal.x ==0 and col.normal.y == 1 then
                p.x = p.x + t*2
                p.y = p.y - t*2
            end
            -- 2
            if len2 ~= 0 and len1 == 0 and len3 == 0 and len4 == 0 and col.normal.x ==-1 and col.normal.y == 0 then
                p.y = p.y + t*2
                p.x = p.x + t*2
            end
            if len2 ~= 0 and len1 == 0 and len3 == 0 and len4 == 0 and col.normal.x ==0 and col.normal.y == 1 then
                p.y = p.y - t*2
                p.x = p.x - t*2
            end
            -- 3
            if len3 ~= 0 and len1 == 0 and len2 == 0 and len4 == 0 and col.normal.x ==-1 and col.normal.y == 0 then
                p.y = p.y - t*2
                p.x = p.x + t*2
            end
            -- 4
            if len4 ~= 0 and len1 == 0 and len2 == 0 and len3 == 0 and col.normal.x ==0 and col.normal.y == -1 then
                p.y = p.y + t*2
                p.x = p.x + t*2
            end
            if len4 ~= 0 and len1 == 0 and len2 == 0 and len3 == 0 and col.normal.x ==1 and col.normal.y == 0 then
                p.y = p.y - t*2
                p.x = p.x - t*2
            end
        end
        print(("col.type = %s, col.normal = %d,%d"):format(col.type, col.normal.x, col.normal.y))
    end
end

helpers.getNearestVisibleEnemy = function(bot)
    local output = {distance = 10000}
    local opponents = filter(handlers.actors, function(actor)
        return actor.index ~= bot.index and actor.alive and actor.team ~= bot.team
    end)
    local visible_opponents = filter(opponents, function(actor)
        return helpers.canBeSeen(bot, actor)
    end)
    if visible_opponents then
        for index, enemy in ipairs(visible_opponents) do
            local distance = helpers.dist(bot, enemy);
            if output.distance > distance and distance < 600 then
                output = {distance = distance, enemy = enemy};
            end
        end
        return output;
    else
        return nil;
    end
end

helpers.getNearestWaypoint = function(bot)
    local output = {distance = 10000, item = nil}
    -- solo quelli non ancora attraversati dallo specifico bot
    local waypoints = filter(handlers.points.waypoints, function(point)
        return point.players[bot.index].visible == true
    end)
    -- solo quelli visibili
    local visible_waypoints =  filter(waypoints, function(point)
        return helpers.canBeSeen(bot, point)
    end)
    if visible_waypoints then
        for index, point in ipairs(visible_waypoints) do
            local distance = helpers.dist(bot, point);
            if output.distance > distance and distance < 2000 then
                output = {distance = distance, item = point};
            end
        end
    end
    return output;
end

helpers.getNearestPowerup = function(bot)
    local output = {distance = 10000, item = nil}
    -- si esclude quelli non visibili (quelli già presi!)
    local visible_powerups = filter(handlers.powerups.powerups, function(point)
        return point.visible == true
    end)
    if visible_powerups and #visible_powerups then
        for index, item in ipairs(visible_powerups) do
            local distance = helpers.dist(bot, item);
            if output.distance > distance and distance < 1000 then
                output = {distance = distance, item = item};
            end
        end
        return output;
    end
end

helpers.findPath = function(bot, target)
    -- non si capisce come mai si debba aumentare di 1 le coordinate di inizio e fine
    -- e poi si deve togliere 1 dai nodi calcolati
    local nodes = {}
    local startx, starty = handlers.pf.worldToTile(bot.x + bot.w / 2 + 32, bot.y + bot.h / 2 + 32)
    local finalx, finaly = handlers.pf.worldToTile(target.x + 32, target.y + 32)
    local path = handlers.pf.calculatePath(startx, starty, finalx, finaly)
    if path then
        print(('Path found! Length: %.2f'):format(path:getLength()))
        for node, count in path:nodes() do
            -- print(('Step: %d - x: %d - y: %d'):format(count, node:getX(),node:getY()))
            table.insert(nodes, {x = node:getX() - 1, y = node:getY() - 1})
        end
    end
    return nodes
end

return helpers
