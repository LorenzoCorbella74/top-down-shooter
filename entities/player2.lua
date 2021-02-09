player = {}

--this is where we set atributes of the player
function player.load()
	player.x = 10
	player.y = 10
	player.width = 48
	player.height = 48
	player.speed = 250
	
	world:add(player, player.x, player.y, player.width, player.height) -- player is in the phisycs world
end

function player.update(dt)
    player.move(dt)
end

--this is where the player is drawn from
function player.draw()
	love.graphics.rectangle("fill",player.x,player.y,player.width,player.height)
end

--this is where the movement is handled
function player.move(dt)
	local futurex = player.x
	local futurey = player.y
	if love.keyboard.isDown("d")  then
		futurex = player.x + player.speed * dt
	end

	if love.keyboard.isDown("a") then
		futurex = player.x - player.speed * dt
	end

	if love.keyboard.isDown("s") then
		futurey = player.y + player.speed * dt
	end

	if love.keyboard.isDown("w") then
		futurey = player.y - player.speed * dt
	end

	-- update the player associated bounding box in the world
	local cols
	
	player.x, player.y, cols, cols_len = world:move(player, futurex, futurey)
    for i=1, cols_len do
      local col = cols[i]
      print(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normal.x, col.normal.y))
    end
end


