FollowerSprites = {
  attract = love.graphics.newImage('assets/beholder.png'),
  repel = love.graphics.newImage('assets/beholder.png'),
  burst = love.graphics.newImage('assets/beholder.png'),
  slow = love.graphics.newImage('assets/beholder.png'),
}


Follower = {
	prototype = {},
	mt = {}
}
Follower.mt.__index = Follower.prototype


function Follower:new(commander, ability)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.commander = commander
  o.x, o.y = math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight())
	o.rotation = 0
	o.ability = ability
	o.sprite = FollowerSprites[ability]
	
	o.offsetX = o.sprite:getWidth() / 2
	o.offsetY = o.sprite:getHeight() / 2
	o.scale = 0.2
	-- Following specifics
	o.commander = commander
	
	return o
end


function Follower.prototype:draw()
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scale, self.scale, self.offsetX * self.scale, self.offsetY * self.scale)
  --love.graphics.circle("fill", self.x, self.y, 10)
end

function Follower.prototype:update()
  -- Update speed
  local xDiff = self.commander.x - self.x;
  local yDiff = self.commander.y - self.y;
  local length = math.sqrt(xDiff * xDiff + yDiff * yDiff)
  
  self.x = self.x + (xDiff / length) * 2
  self.y = self.y + (yDiff / length) * 2
end
