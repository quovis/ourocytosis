Follower = {
	prototype = {},
	mt = {}
}
Follower.mt.__index = Follower.prototype


function Follower:new(commander)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.commander = commander
  o.x, o.y = o.commander.x, o.commander.y
	o.rotation = 0
	o.sprite = love.graphics.newImage('assets/beholder.png')
	
	o.offsetX = o.sprite:getWidth() / 2
	o.offsetY = o.sprite:getHeight() / 2
	o.scale = 0.2
	-- Following specifics
	o.commander = commander
	
	return o
end


function Follower.prototype:draw()
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scale, self.scale, self.offsetX * self.scale, self.offsetY * self.scale)
end

function Follower.prototype:update()
  -- Update speed
  --local xDiff = self.commander.x - self.x;
  --local yDiff = self.commander.y - self.y;
  
  
  
  self.rotation = math.atan2(xIncrement, -yIncrement)
  
  self.x = self.x + xIncrement
  self.y = self.y + yIncrement
end
