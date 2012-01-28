Commander = {
	prototype = {},
	mt = {}
}

Commander.mt.__index = Commander.prototype

function Commander:new(x, y, sprite, followersCount, ability)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.x, o.y = x, y
	o.rotation = 0
	o.sprite = sprite
	o.offsetX = sprite:getWidth() / 2
	o.offsetY = sprite:getHeight() / 2
	o.ability = ability
	
	o.followers = {}
	for i = 0, followersCount - 1 do
	  o.followers[i] = Follower:new(o)
	end
	
	return o
end

function Commander.prototype:draw()
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 1, 1, self.offsetX, self.offsetY)
end

function Commander.prototype:move(xIncrement, yIncrement)

  self.rotation = math.atan2(xIncrement, -yIncrement)

  self.x = self.x + xIncrement
  self.y = self.y + yIncrement
end
