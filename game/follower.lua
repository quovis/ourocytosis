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
  CommanderReductionByFrame = 0.0001,
  CommanderRepelFactor = 4,
  MinimumVelocityModulation = 0.3,

  ScreenPartitionCountBySide = 10,
  screenPartitions = {},
}

Follower.mt.__index = Follower.prototype

function Follower:initializePartitions()
  for i = 1, Follower.ScreenPartitionCountBySide do
    self.screenPartitions[i] = {}
    for j = 1, Follower.ScreenPartitionCountBySide do
      self.screenPartitions[i][j] = { x = 0, y = 0, count = 0}
    end
  end
end

function Follower:calculatePartitionsWeightCenters(followers) 
  -- Zero values for partitions
  for i = 1, Follower.ScreenPartitionCountBySide do
    for j = 1, Follower.ScreenPartitionCountBySide do
      self.screenPartitions[i][j].x = 0
      self.screenPartitions[i][j].y = 0
      self.screenPartitions[i][j].count = 0
    end
  end
  
  -- Calculate weights
  local partitionWidthInverse = Follower.ScreenPartitionCountBySide / love.graphics.getWidth()
  local partitionHeightInverse = Follower.ScreenPartitionCountBySide / love.graphics.getHeight()

  for i = 1, #followers do
    local x = followers[i].x
    local y = followers[i].y
    
    local partitionColumn = math.floor(partitionWidthInverse * x) + 1
    local partitionRow = math.floor(partitionHeightInverse * y) + 1
    
    local partition = self.screenPartitions[partitionColumn][partitionRow]
    partition.x = partition.x + x
    partition.y = partition.y + y
    partition.count = partition.count + 1

    followers[i].partition.column = partitionColumn
    followers[i].partition.row = partitionRow
  end

  -- Calculate Averages
  for i = 1, Follower.ScreenPartitionCountBySide do
    for j = 1, Follower.ScreenPartitionCountBySide do
      local partition = self.screenPartitions[i][j]
      partition.x = partition.x / partition.count
      partition.y = partition.y / partition.count
    end
  end
end

function Follower:new(commander, ability)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.commander = commander
  o.x, o.y = math.random(0, love.graphics.getWidth() - 1), math.random(0, love.graphics.getHeight() - 1)
	o.rotation = 0
	o.ability = ability
	o.sprite = FollowerSprites[ability]
	o.offsetX = o.sprite:getWidth() / 2
	o.offsetY = o.sprite:getHeight() / 2
	o.scale = 0.2 * 0.5

  o.velocity = { x = o.x - o.commander.x / 60.0, y = o.y - o.commander.y / 60.0}	
  o.maxVelocitySquare = math.random(1, 4)
  o.randomVelocityFactor = math.random(1,1000)
  o.commanderDistanceThreshold = math.random(10000, 50000)
  o.partition = { column = 0, row = 0 }
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
  local cDistanceX = (self.x - self.commander.x) 
  local cDistanceY = (self.y - self.commander.y) 

  -- Modulate the difference to a small number in order to sum just a little in this frame
  local cXDiff = (cDistanceX * Follower.CommanderReductionByFrame)
  local cYDiff = (cDistanceY * Follower.CommanderReductionByFrame)
  
  -- If the distance is greater than the commanderDistanceThreshold (all squared), invert the direction
  -- and increase the velocity to make a 'let him pass' effect.
  if cDistanceX * cDistanceX + cDistanceY * cDistanceY < self.commanderDistanceThreshold then
    cXDiff = -( Follower.CommanderRepelFactor * (cXDiff + 0.1) )
    cYDiff = -( Follower.CommanderRepelFactor * (cYDiff + 0.1) )
  end

  -- Add commander difference to the velocity
  self.velocity.x = self.velocity.x + cXDiff
  self.velocity.y = self.velocity.y + cYDiff
  
  -- Fix position related to followers
  local partition = Follower.screenPartitions[self.partition.column][self.partition.row]
  local fDistanceX = self.x - partition.x
  local fDistanceY = self.y - partition.y

  fXDiff = -( fDistanceX * Follower.CommanderReductionByFrame )
  fYDiff = -( fDistanceY * Follower.CommanderReductionByFrame )
  
  self.velocity.x = self.velocity.x + (fXDiff * Follower.CommanderRepelFactor * 5)
  self.velocity.y = self.velocity.y + (fYDiff * Follower.CommanderRepelFactor * 5)

  -- If the velocity is higher than our max velocity we slow down a bit
  if self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.x > self.maxVelocitySquare then
    self.velocity.x = self.velocity.x * Follower.VelocityCapReduction
    self.velocity.y = self.velocity.y * Follower.VelocityCapReduction
  end
 
  -- We apply the velocity to the current position modulated by a sine function in order to get a sluggish movement
  self.x = self.x - self.velocity.x --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))
  self.y = self.y - self.velocity.y --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))
  
  if self.x < 0 then
    self.x = 0
  end

  if self.x > love.graphics.getWidth() then
    self.x = love.graphics.getWidth() - 1
  end

  if self.y < 0 then
    self.y = 0
  end

  if self.y > love.graphics.getHeight() then
    self.y = love.graphics.getHeight() - 1
  end

  -- We reduce the velocity by a hardcoded factor (it looked better)
  self.velocity.x = self.velocity.x * Follower.ReductionCoefficient
  self.velocity.y = self.velocity.y * Follower.ReductionCoefficient
end
