FollowerSprites = {
  attract = love.graphics.newImage('assets/beholder.png'),
  repel = love.graphics.newImage('assets/beholder.png'),
  burst = love.graphics.newImage('assets/beholder.png'),
  slow = love.graphics.newImage('assets/beholder.png'),
}

Follower = {
	prototype = {},
	mt = {},

  -- Constants:

  MIN_COMMANDER_DISTANCE_THRESHOLD = 500,
  MAX_COMMANDER_DISTANCE_THRESHOLD = 1000,

  COMMANDER_REPULSION_FACTOR = 20,

  FOLLOWERS_REPULSION_FACTOR = 8,

  DISTANCE_TO_FRAME_DIFF = 0.0001,

  ReductionCoefficient = 0.95,
  VelocityCapReduction = 0.97,
  CommanderReductionByFrame = 0.0001,
  MinimumVelocityModulation = 0.3,

  ScreenPartitionCountBySide = 30,
  screenPartitions = {}
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
    
    --print("X: " .. x .. ", Y: " .. y)

    local partition = self.screenPartitions[partitionColumn][partitionRow]
    partition.x = partition.x + x
    partition.y = partition.y + y
    partition.count = partition.count + 1

    --print("partition.count: " .. partition.count)

    followers[i].partition.column = partitionColumn
    followers[i].partition.row = partitionRow
  end
  
  -- Calculate Averages
  for i = 1, Follower.ScreenPartitionCountBySide do
    for j = 1, Follower.ScreenPartitionCountBySide do
      local partition = self.screenPartitions[i][j]
      if partition.count > 0 then
        partition.x = partition.x / partition.count
        partition.y = partition.y / partition.count
      else
        partition.x = nil
        partition.y = nil
      end
    end
  end
end

function Follower:new(commander, ability)
	local o = {}
	setmetatable(o, self.mt)
	
  -- Position
  --o.x, o.y = math.random(0, love.graphics.getWidth() - 1), math.random(0, love.graphics.getHeight() - 1)
  o.x = commander.x + math.random(-200, 200)
  o.y = commander.y + math.random(-200, 200)

  -- Commander
	o.commander = commander

  -- Ability
	o.ability = ability

  -- Sprite info
	o.rotation = 0
	o.sprite = FollowerSprites[ability]
	o.offsetX = o.sprite:getWidth() / 2
	o.offsetY = o.sprite:getHeight() / 2
	o.scale = 0.2 * 0.5

  o.velocity = { x = 0, y = 0 }

  o.commanderDistanceThreshold = math.random(Follower.MIN_COMMANDER_DISTANCE_THRESHOLD, Follower.MAX_COMMANDER_DISTANCE_THRESHOLD)

  o.maxVelocitySquare = math.random(1, 4)
  o.randomVelocityFactor = math.random(1,1000)
  o.partition = { column = 0, row = 0 }
  o.beingAttracted = {}
  o.beingSlowed = {}
	-- Following specifics
	o.commander = commander
  
  o.escapeDirectionX = math.random(-1, 1) * 0.01
  o.escapeDirectionY = math.random(-1, 1) * 0.01

	return o
end

function Follower.prototype:update()
  -- Calculate the distance between the commander and the follower
  local cDistanceX = (self.x - self.commander.x) 
  local cDistanceY = (self.y - self.commander.y) 

  -- Modulate the difference to a small number in order to sum just a little in this frame
  local cXDiff = (cDistanceX * Follower.DISTANCE_TO_FRAME_DIFF)
  local cYDiff = (cDistanceY * Follower.DISTANCE_TO_FRAME_DIFF)

  if cDistanceX * cDistanceX + cDistanceY * cDistanceY < self.commanderDistanceThreshold then
    cXDiff = Follower.COMMANDER_REPULSION_FACTOR * -(cXDiff + self.escapeDirectionX)
    cYDiff = Follower.COMMANDER_REPULSION_FACTOR * -(cYDiff + self.escapeDirectionY)
  end

  -- Attract
  for i = 0, #self.beingAttracted do
    local attractDirection = self.beingAttracted[i]
    if attractDirection then
      distanceX = self.x - attractDirection.x
      distanceY = self.y - attractDirection.y
      if (distanceX < 200 and distanceX > -200) and (distanceY < 200 and distanceY > -200) then
        self.velocity.x = self.velocity.x + distanceX * 0.01
        self.velocity.y = self.velocity.y + distanceY * 0.01
      end
    end
  end

  self.beingAttracted = {}



  -- Add commander difference to the velocity
  self.velocity.x = self.velocity.x + cXDiff
  self.velocity.y = self.velocity.y + cYDiff
  
  -- Fix position related to followers
  local partition = Follower.screenPartitions[self.partition.column][self.partition.row]
  local fDistanceX = self.x - partition.x
  local fDistanceY = self.y - partition.y

  --local partitionXAvg = 0
  --local partitionYAvg = 0
  --local partitionsCount = 0

  --for i = -1, 1 do
  --  local column = Follower.screenPartitions[self.partition.column + i]
  --  if column then
  --    for j = -1, 1 do
  --      local partition = column[self.partition.row + j]
  --      if partition and partition.x and partition.y then
  --        partitionsCount = partitionsCount + 1
  --        --print("partition.x: " .. partition.x .. ", partition.y:" .. partition.y)
  --        partitionXAvg = partitionXAvg + partition.x
  --        partitionYAvg = partitionYAvg + partition.y
  --      end
  --    end
  --  end
  --end

  --local fDistanceX = 0
  --local fDistanceY = 0

  --if partitionsCount > 0 then
  --  --print("partitionsCount: " .. partitionsCount)
  --  partitionXAvg = partitionXAvg / partitionsCount
  --  partitionYAvg = partitionYAvg / partitionsCount
  --  --print("partitionXAvg: " .. partitionXAvg .. ", partitionYAvg: " .. partitionYAvg)
  --  fDistanceX = self.x - partitionXAvg
  --  fDistanceY = self.y - partitionYAvg
  --end

  local fXDiff = -(fDistanceX * Follower.DISTANCE_TO_FRAME_DIFF)
  local fYDiff = -(fDistanceY * Follower.DISTANCE_TO_FRAME_DIFF)
  
  self.velocity.x = self.velocity.x + (fXDiff * Follower.FOLLOWERS_REPULSION_FACTOR)
  self.velocity.y = self.velocity.y + (fYDiff * Follower.FOLLOWERS_REPULSION_FACTOR)

  -- If the velocity is higher than our max velocity we slow down a bit
  if self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.x > self.maxVelocitySquare then
    self.velocity.x = self.velocity.x * Follower.VelocityCapReduction
    self.velocity.y = self.velocity.y * Follower.VelocityCapReduction
  end
 
  -- We apply the velocity to the current position modulated by a sine function in order to get a sluggish movement
  self.x = self.x - self.velocity.x --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))
  self.y = self.y - self.velocity.y --* (Follower.MinimumVelocityModulation + math.abs(math.sin(love.timer.getTime() + self.randomVelocityFactor)))
  
  -- Bind to the screen
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

function Follower.prototype:attracted(x, y)
  table.insert(self.beingAttracted, {x = x, y = y})
end

function Follower.prototype:slowed(x, y)
  table.insert(self.beingSlowed, {x = x, y = y})
end

function Follower.prototype:draw()
  love.graphics.setColorMode('modulate')
  love.graphics.setColor(self.commander.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scale, self.scale, self.offsetX * self.scale, self.offsetY * self.scale)
end
