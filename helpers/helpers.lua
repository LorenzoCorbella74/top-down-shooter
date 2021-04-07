local config = require "config"

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

local gameTypes_priorities = {
    deathmatch = {health = .5, special_powerup = 1, ammo = .5, weapon = .75},
    team_deathmatch = {
        health = .5,
        special_powerup = 1,
        ammo = .5,
        weapon = .75
    },
    ctf = {
        health = .5,
        special_powerup = 1,
        ammo = .5,
        weapon = .75,
        objectives = 0.9 -- recupero enemy_flag e team_flag
    } --[[ ,
    -- gare ad obiettivi
    missions = {
        health = .5,
        special_powerup = 1,
        ammo = .5,
        weapon = .75,
        objectives = 0.9
    } ]]
}

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
    local delta = math.rad(self.parameters.view_angle) -- angle extent
    local vision_length = self.parameters.view_length -- distance with target
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
    -- to perfezionare ...
    local movementfilter = function(item)
        if item.name == "waypoint" then
            return false
        elseif item.type == 'powerups' then
            return false
        elseif item.type == 'ammo' then
            return false
        elseif item.type == 'weapons' then
            return false
        else
            return true
        end
    end
    local items, len = world:querySegment(point_sight.x, point_sight.y, entity.x, entity.y, movementfilter)
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
            if p.name ~= 'player' then
                handlers.powerups.trackBot(item.id, p)
            end
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
            handlers.powerups.trackBot(item.id, p)
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
            -- print(tostring(len1), tostring(len2), tostring(len3), tostring(len4))
            -- 1  2
            -- 4  3

            -- 1
            if len1 ~= 0 and len2 == 0 and len3 == 0 and len4 == 0 and
                col.normal.x == 1 and col.normal.y == 0 then
                p.x = p.x - t * 2
                p.y = p.y + t * 2
            end
            if len1 ~= 0 and len2 == 0 and len3 == 0 and len4 == 0 and
                col.normal.x == 0 and col.normal.y == 1 then
                p.x = p.x + t * 2
                p.y = p.y - t * 2
            end
            -- 2
            if len2 ~= 0 and len1 == 0 and len3 == 0 and len4 == 0 and
                col.normal.x == -1 and col.normal.y == 0 then
                p.y = p.y + t * 2
                p.x = p.x + t * 2
            end
            if len2 ~= 0 and len1 == 0 and len3 == 0 and len4 == 0 and
                col.normal.x == 0 and col.normal.y == 1 then
                p.y = p.y - t * 2
                p.x = p.x - t * 2
            end
            -- 3
            if len3 ~= 0 and len1 == 0 and len2 == 0 and len4 == 0 and
                col.normal.x == -1 and col.normal.y == 0 then
                p.y = p.y - t * 2
                p.x = p.x + t * 2
            end
            -- 4
            if len4 ~= 0 and len1 == 0 and len2 == 0 and len3 == 0 and
                col.normal.x == 0 and col.normal.y == -1 then
                p.y = p.y + t * 2
                p.x = p.x + t * 2
            end
            if len4 ~= 0 and len1 == 0 and len2 == 0 and len3 == 0 and
                col.normal.x == 1 and col.normal.y == 0 then
                p.y = p.y - t * 2
                p.x = p.x - t * 2
            end
        end
        -- print(("col.type = %s, col.normal = %d,%d"):format(col.type, col.normal.x, col.normal.y))
    end
end

helpers.getNearestVisibleEnemy = function(bot)
    local output = {distance = 10000}
    local opponents = filter(handlers.actors, function(actor)
        return actor.index ~= bot.index and actor.alive and actor.team ~=
                   bot.team
    end)
    local visible_opponents = filter(opponents, function(actor)
        return helpers.canBeSeen(bot, actor) and not actor.invisible
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

helpers.randomDirection = function(bot)
    local directions = {bot.velX, -bot.velX, -bot.velY, bot.velY}
    return directions[math.random(#directions)]
end

helpers.getRandomtWaypoint = function(bot)
    local output = {distance = 10000, item = nil}
    -- solo quelli che possono essere visti...
    local visible_waypoints = filter(handlers.points.waypoints, function(point)
        return helpers.canBeSeen(bot, point)
    end)
    -- solo quelli non ancora attraversati dallo specifico bot ed ad una certa distanza
    local waypoints = filter(visible_waypoints, function(point)
        return point.players[bot.index].visible == true and
                   helpers.dist(bot, point) < 1200
    end)
    if waypoints then
        -- random choice...
        local random_waypoint = waypoints[math.random(#waypoints)]
        if random_waypoint then
            local distance = helpers.dist(bot, random_waypoint)
            output = {distance = distance, item = random_waypoint};
        end
    end
    return output;
end

helpers.weaponIsNotYetOwn = function(weapon, actor)
    return not actor.weaponsInventory.checkAvailability(weapon)
end

helpers.logistic = function(x, threshold)
    return 1 / (1 + (2.718 * 0.45) ^ (x + threshold))
end
helpers.exponential = function(x, exponent)
    return (100 - x ^ exponent) / (100 ^ exponent)
end

helpers.calcDesiderability = function(item, bot)
    local output
    local health = bot.hp + bot.ap
    local health_threshold = 40
    -- if health type
    if item.info.type == 'health' and health < health_threshold then
        output = 1
    else
        output = helpers.logistic(health, health_threshold)
    end
    -- if weapon type desiderability is calculated according to bot weapons preferences
    if item.info.type == 'weapon' and helpers.weaponIsNotYetOwn(item, bot) then
        output = 1 * bot.weapons_preferences[item.info.name]
    elseif item.info.type == 'weapon' then
        output = 0.5 * bot.weapons_preferences[item.info.name] --  half of desiderability if already owned
    end
    -- if ammo type
    if item.info.type == 'ammo' then
        local ratio = bot.weaponsInventory.selectedWeapon.shotNumber / bot.weaponsInventory.selectedWeapon.complete
        output = helpers.exponential(ratio, 4)
    end
    -- if special powerups
    if item.info.type == 'special_powerup' then output = 1 end

    -- if game is type team and bot role is appropiate -> to to item or tactical waypoint

    return output
end

helpers.getObjective = function(bot)
    local priorities = gameTypes_priorities[config.GAME.MATCH_TYPE]

    -- get only the visible one or the ones that cannot be seen (and the ones not crossed recently)
    local visible_powerups = filter(handlers.powerups.powerups, function(point)
        return (point.players[bot.index].visible == true and point.visible == true) or
                   (point.players[bot.index].visible == true and point.visible == false and not helpers.canBeSeen(bot, point))
    end)
    if visible_powerups and #visible_powerups > 0 then
        for index, item in ipairs(visible_powerups) do
            -- local path, distance = helpers.findPath(bot, item);
            item.distance = helpers.dist(bot, item);
            item.score = priorities[item.info.type] * (1 / item.distance) * helpers.calcDesiderability(item, bot)
        end
        table.sort(visible_powerups, function(a, b)
            return a.score > b.score
        end)
        return {
            item = visible_powerups[1],
            distance = visible_powerups[1].distance
        }
    end
    return nil
end

helpers.findPath = function(bot, target)
    -- non si capisce come mai si debba aumentare di 1 le coordinate di inizio e fine
    -- e poi si deve togliere 1 dai nodi calcolati
    local nodes = {}
    local startx, starty = handlers.pf.worldToTile(bot.x + bot.w / 2 + 32, bot.y + bot.h / 2 + 32)
    local finalx, finaly = handlers.pf.worldToTile(target.x + 32, target.y + 32)
    local path = handlers.pf.calculatePath(startx, starty, finalx, finaly)
    if path then
        print(('Path found! Length: %.2f'):format(path:getLength()), bot.x, target.x, bot.y, target.y)
        for node, count in path:nodes() do
            -- print(('Step: %d - x: %d - y: %d'):format(count, node:getX(),node:getY()))
            table.insert(nodes, {x = node:getX() - 1, y = node:getY() - 1})
        end
    end
    return nodes, path:getLength()
end

return helpers
