local layer = map:addCustomLayer("Sprites", 4)

-- Get player spawn object
local player
for k, object in pairs(map.objects) do
    print(k)
    if object.name == "spawn" then
        player = object
        break
    end
end

-- Create player object
local sprite = love.graphics.newImage("myTiles/tiles/21.png")

layer.player = {
    sprite = sprite,
    x = player.x,
    y = player.y,
    speed = 256, -- pixels per second
    width = sprite:getWidth(),
    height = sprite:getHeight(),

    hp = 100
}

world:add(layer.player, layer.player.x, layer.player.y, layer.player.width,
          layer.player.height) -- player is in the phisycs world

-- Add controls to player
layer.update = function(self, dt)
    local futurex = self.player.x
    local futurey = self.player.y
    -- Move player up
    if love.keyboard.isDown("w", "up") then
        futurey = self.player.y - self.player.speed * dt
    end

    -- Move player down
    if love.keyboard.isDown("s", "down") then
        futurey = self.player.y + self.player.speed * dt
    end

    -- Move player left
    if love.keyboard.isDown("a", "left") then
        futurex = self.player.x - self.player.speed * dt
    end

    -- Move player right
    if love.keyboard.isDown("d", "right") then
        futurex = self.player.x + self.player.speed * dt
    end

    local cols

    -- update the player associated bounding box in the world
    self.player.x, self.player.y, cols, cols_len =
        world:move(self.player, futurex, futurey)
    for i = 1, cols_len do
        local col = cols[i]
        if (col.other.name == 'health' and col.other.visible) then
            self.player.hp = self.player.hp + col.other.properties.points
            col.other.visible = false
            world:remove(col.other) -- powerup is no more in the phisycs world
        end

        print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(
                  col.other, col.type, col.normal.x, col.normal.y))
    end
end

-- Draw player
layer.draw = function(self)
    love.graphics.draw(self.player.sprite, math.floor(self.player.x),
                       math.floor(self.player.y), 0, 1, 1)
end

return layer
