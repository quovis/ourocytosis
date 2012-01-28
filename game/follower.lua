Follower = {
	prototype = {},
	mt = {}
}
Follower.mt.__index = Follower.prototype


function Follower:new(x, y, sprite, player)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.x, o.y = x, y
	o.rotation = 0
	o.sprite = sprite
	o.offsetX = sprite:getWidth() / 2
	o.offsetY = sprite:getHeight() / 2
	
	-- Following specifics
	o.player = player
	
	return o
end


function Follower.prototype:draw()
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 1, 1, self.offsetX, self.offsetY)
end

function Follower.prototype:update()
  -- Update speed
  local xDiff = self.player.x - self.x;
  local yDiff = self.player.y - self.y;
  
  self.rotation = math.atan2(xIncrement, -yIncrement)
  
  self.x = self.x + xIncrement
  self.y = self.y + yIncrement
end
