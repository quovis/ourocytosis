Commander = {
	prototype = {},
	mt = {},
	
	-- Constants
  FastSpeedRate = 2,
  NormalSpeedRate = 1,
  SlowSpeedRate = 0.5
}

Commander.mt.__index = Commander.prototype

function Commander:new(x, y, sprite, color)
	local o = {}
	setmetatable(o, self.mt)
	
	-- Position
	o.x, o.y = x, y
  o.dx, o.dy = 0, 0

  -- Sprite info
	o.rotation = 0
	o.sprite = sprite
	o.offsetX = sprite:getWidth() / 2
	o.offsetY = sprite:getHeight() / 2
	o.color = color

  -- Followers
	o.followers = {}
  
  -- Lasso
  o.lasso = Lasso:new(x, y, color)
  
	-- Abilities
  -- Ability points
	o.abilityPoints = {}
  o.abilityPointsUsed = {}
  o.abilityActive = {}
  o.abilityPointStartTime = {}
  --o.abilityPointDuration = {}
  o.beingRepelled = {}
	for i = 1, #Abilities do
	  o.abilityPoints[Abilities[i]] = 0
  	o.abilityPointsUsed[Abilities[i]] = o.abilityPoints[Abilities[i]]
  	o.abilityActive[Abilities[i]] = false
  	o.abilityPointStartTime[Abilities[i]] = 0
	end
  
	-- Speed abilities
	o.speedRate = Commander.NormalSpeedRate
	return o
end

function Commander.prototype:move(dx, dy)
  self.rotation = math.atan2(dx, -dy)
  self.dx, self.dy = dx, dy
end

function Commander.prototype:draw()
  -- Draw lasso
  self.lasso:draw()

  -- Draw commander
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 0.25, 0.25, self.offsetX, self.offsetY)
end

function Commander.prototype:update()
  -- Update abilities
  -- reset ability effects
  self.speedRate = Commander.NormalSpeedRate

  -- apply ability effects if active
  for i = 1, #Abilities do
    local ability = Abilities[i]
    local currentTime = love.timer.getTime()
  
    if self.abilityActive[ability] then
      -- player is trying to use the ability
      if (currentTime - self.abilityPointStartTime[ability] > AbilityPointDuration) then
        if self.abilityPointsUsed[ability] < self.abilityPoints[ability] then
          -- consume one point
          self.abilityPointsUsed[ability] = self.abilityPointsUsed[ability] + 1
          -- restart the point timer
          self.abilityPointStartTime[ability] = currentTime
        
          -- TODO: deactivate ability here for optimization
          self:applyAbility(ability)
        end
      else
        self:applyAbility(ability)
      end
    else
      -- player is not trying to use the ability
    
      -- if there are points to be regained and the time has passed
      if (self.abilityPointsUsed[ability] > 0 and (currentTime - self.abilityPointStartTime[ability] > AbilityPointDuration)) then
        -- gain one point
        self.abilityPointsUsed[ability] = self.abilityPointsUsed[ability] - 1
        -- restart the point timer
        self.abilityPointStartTime[ability] = currentTime
      end
    end
  end
  
  
  -- Update position
  -- Repel
  for i = 0, #self.beingRepelled do
    local repelDirection = self.beingRepelled[i]
    if repelDirection then
      distanceX = self.x - repelDirection.x
      distanceY = self.y - repelDirection.y
      if (distanceX < 100 and distanceX > -100) and (distanceY < 100 and distanceY > -100) then
        self.dx = self.dx + distanceX * 0.05
        self.dy = self.dy + distanceY * 0.05
      end
    end
  end

  self.beingRepelled = {}
  
  self.x = self.x + self.dx * self.speedRate
  self.y = self.y + self.dy * self.speedRate
  
  -- Update lasso
  self.lasso:setPosition(self.x, self.y)
  self.lasso:update()

  -- Check if the lasso was closed
  if self.lasso.closed then
    -- Grab new followers
    local match = Game:currentMatch()

    for i = 1, #match.commanders do
      local commander = match.commanders[i]

      -- Avoid grabbing our own followers
      if commander ~= self then
        for j = 1, #commander.followers do
          local follower = commander.followers[j]

          if follower and self.lasso:isInside(follower.x, follower.y) then
            table.insert(self.followers, follower)
            table.remove(commander.followers, j)
            follower.commander = self
          end
        end
      end
    end

    -- Destroy lasso
    self.lasso:destroy()

    -- Create new lasso
    self.lasso = Lasso:new(self.x, self.y, self.color)
  end
end

function Commander.prototype:gainFollower(follower)
  self.abilityPoints[follower.ability] = self.abilityPoints[follower.ability] + 1
  table.insert(self.followers, follower)
end

function Commander.prototype:loseFollowers(followerIndices)
  for i = 1, #followerIndices do
    local index = followerIndices[i]
    local ability = self.followers[index].ability
    self.abilityPoints[ability] = self.abilityPoints[ability] - 1
    table.remove(self.followers, index)
  end
end


-- Abilities
function Commander.prototype:applyAbility(ability)
-- If the button was just pressed, reset the timer
  if (not self.abilityActive[ability]) then
    self.abilityPointStartTime[ability] = love.timer.getTime()
  end
  
  self.abilityActive[ability] = true
  
  -- apply ability effect
  if (ability == 'burst') then
    self.speedRate = Commander.FastSpeedRate
  elseif (ability == 'slow') then
    for i = 1, #Game.match.followers do
      local follower = Game.match.followers[i]
      follower:slowed(self.x, self.y)
    end
  elseif (ability == 'repel') then
    for i = 1, #Game.match.commanders do
      local commander = Game.match.commanders[i]
      if commander ~= self then
        commander:repel(self.x, self.y)
      end
    end
  elseif (ability == 'attract') then
    for i = 1, #Game.match.followers do
      local follower = Game.match.followers[i]
      follower:attracted(self.x, self.y)
    end
  end
end

function Commander.prototype:stopAbility(ability)
  
  -- If the button was just released, reset the timer
  if (self.abilityActive[ability]) then
    self.abilityPointStartTime[ability] = love.timer.getTime()
  end
  
  self.abilityActive[ability] = false
end


function Commander.prototype:repel(x, y)
  table.insert(self.beingRepelled, {x = x, y = y})
end

--function Commander.prototype:burst()

