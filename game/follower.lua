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


followerRadius = 13
followerRadiusSquared = followerRadius * followerRadius


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
  love.graphics.setColorMode('modulate')
  love.graphics.setColor(self.commander.color.red, self.commander.color.green, self.commander.color.blue, self.commander.color.alpha )
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scale, self.scale, self.offsetX * self.scale, self.offsetY * self.scale)
  --love.graphics.circle("fill", self.x, self.y, 10)
  love.graphics.setColorMode('replace')
end

function Follower.prototype:update()
  -- Update speed
  local xDiff = self.commander.x - self.x;
  local yDiff = self.commander.y - self.y;
  local length = math.sqrt(xDiff * xDiff + yDiff * yDiff)
  
  -- Separate from other followers
  local stepX = (xDiff / length)
  local stepY = (yDiff / length)
  local collision = false
  
  for i = 0, #self.commander.followers do
    local f = self.commander.followers[i]
    if f ~= self then
      local fXDiff = self.x + stepX - f.x
      local fYDiff = self.y + stepY - f.y
      local fDistanceSquared = fXDiff * fXDiff + fYDiff * fYDiff
      collision = 4 * followerRadiusSquared > fDistanceSquared
      if collision and fDistanceSquared > 0.01 then
        local overlappingDistance = 2 * followerRadius - math.sqrt(fDistanceSquared)
        stepX = stepX * (fXDiff - overlappingDistance)
        stepY = stepY * (fYDiff - overlappingDistance)
        break
      end
    end
  end
  
  self.x = self.x + stepX
  self.y = self.y + stepY
end
