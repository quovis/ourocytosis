FollowerSprites = {
  attract = love.graphics.newImage('assets/beholder.png'),
  repel = love.graphics.newImage('assets/beholder.png'),
  burst = love.graphics.newImage('assets/beholder.png'),
  slow = love.graphics.newImage('assets/beholder.png'),
}


Follower = {
	prototype = {},
	mt = {},
  ReductionCoefficient = 0.95,
  VelocityCapReduction = 0.97,
  ReductionByFrame = 1.0 / 500.0,
  CommanderReductionByFrame = 0.001,
  CommanderRepelFactor = 4,
  MinimumVelocityModulation = 0.3
}
Follower.mt.__index = Follower.prototype

function Follower:new(commander, ability)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.commander = commander
  o.x, o.y = commander.x, commander.y -- math.random(0, love.graphics.getWidth()), math.random(0, love.graphics.getHeight())
	o.rotation = 0
	o.ability = ability
	o.sprite = FollowerSprites[ability]
	o.offsetX = o.sprite:getWidth() / 2
	o.offsetY = o.sprite:getHeight() / 2
	o.scale = 0.2 * 0.5

  o.velocity = { x = o.x - o.commander.x / 60.0, y = o.y - o.commander.y / 60.0}	
  o.maxVelocitySquare = math.random(1, 4)
  o.randomVelocityFactor = math.random(1,1000)
  
  o.followerDistanceThreshold = math.random(1000, 10000)
  o.commanderDistanceThreshold = math.random(10000, 50000)
  o.cDistance = { x = 0, y = 0 }
	-- Following specifics
	o.commander = commander
	return o
end

function Follower.prototype:draw()
  love.graphics.setColorMode('modulate')
  love.graphics.setColor(self.commander.color.red, self.commander.color.green, self.commander.color.blue, self.commander.color.alpha )
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scale, self.scale, self.offsetX * self.scale, self.offsetY * self.scale)
  love.graphics.setColorMode('replace')
end

function Follower.prototype:update()
  -- Calculate the distance between the commander and the follower
  self.cDistance.x = (self.x - self.commander.x) 
  self.cDistance.y = (self.y - self.commander.y) 

  -- Modulate the difference to a small number in order to sum just a little in this frame
  local cXDiff = (self.cDistance.x * Follower.CommanderReductionByFrame)
  local cYDiff = (self.cDistance.y * Follower.CommanderReductionByFrame)
  
  -- If the distance is greater than the commanderDistanceThreshold (all squared), invert the direction
  -- and increase the velocity to make a 'let him pass' effect.
  if self.cDistance.x * self.cDistance.x + self.cDistance.y * self.cDistance.y < self.commanderDistanceThreshold then
    cXDiff = -( Follower.CommanderRepelFactor * (cXDiff + 0.1) )
    cYDiff = -( Follower.CommanderRepelFactor * (cYDiff + 0.1) )
  end

  -- Add commander difference to the velocity
  self.velocity.x = self.velocity.x + cXDiff
  self.velocity.y = self.velocity.y + cYDiff

  -- Let's iterate through all the followers to avoid collisions
  local fXDiff = 0
  local fYDiff = 0

  local fdt = self.followerDistanceThreshold

  for i = 0, #self.commander.followers do
    local f = self.commander.followers[i]

    ---- Calculate the direction between the current follower and me
    local fDirectionX = self.x - f.x
    local fDirectionY = self.y - f.y
    --
    ---- If the distance to the current follower is less than the threshold (all squared) we move away
    ---- in the inverse direction

    ---- Using circles
    if fDirectionX * fDirectionX + fDirectionY * fDirectionY < self.followerDistanceThreshold then
      fXDiff = fXDiff + fDirectionX
      fYDiff = fYDiff + fDirectionY
      --self.velocity.x = self.velocity.x - fDirectionX * Follower.ReductionByFrame
      --self.velocity.y = self.velocity.y - fDirectionY * Follower.ReductionByFrame
    end

    -- Using squares
    -- if fDirectionX < fdt and fDirectionX > -fdt then
    --   self.velocity.x = self.velocity.x - fDirectionX * Follower.ReductionByFrame
    --   --fXDiff = fXDiff + fDirectionX
    -- end
    -- if fDirectionY < fdt and fDirectionY > -fdt then 
    --   self.velocity.y = self.velocity.y - fDirectionY * Follower.ReductionByFrame
    --   --fYDiff = fYDiff + fDirectionY
    -- end
  end

  self.velocity.x = self.velocity.x - fXDiff * Follower.ReductionByFrame 
  self.velocity.y = self.velocity.y - fYDiff * Follower.ReductionByFrame

  -- If the velocity is higher than our max velocity we slow down a bit
  if self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.x > self.maxVelocitySquare then
    self.velocity.x = self.velocity.x * Follower.VelocityCapReduction
    self.velocity.y = self.velocity.y * Follower.VelocityCapReduction
  end
  
  -- We apply the velocity to the current position modulated by a sine function in order to get a sluggish movement
  self.x = self.x - self.velocity.x --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))
  self.y = self.y - self.velocity.y --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))

  -- We reduce the velocity by a hardcoded factor (it looked better)
  self.velocity.x = self.velocity.x * Follower.ReductionCoefficient
  self.velocity.y = self.velocity.y * Follower.ReductionCoefficient
end
