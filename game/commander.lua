Commander = {
	prototype = {},
	mt = {},
	
	-- Constants
  FastSpeedRrate = 2.5,
  NormalSpeedRate = 1.5,
  SlowSpeedRrate = 0.5
}

Commander.mt.__index = Commander.prototype


function Commander:new(x, y, sprite, color)
	local o = {}
	setmetatable(o, self.mt)
	
	-- Initialization
	o.x, o.y = x, y
	o.rotation = 0
	o.sprite = sprite
	o.offsetX = sprite:getWidth() / 2
	o.offsetY = sprite:getHeight() / 2
	o.color = color
	o.followers = {}
  
  o.xIncrement = 0
  o.yIncrement = 0
  
  -- Initialize lasso
  o.lasso = Lasso:new(x, y, color)
  
	-- Abilities
  -- Ability points
	o.abilityPoints = {}
  o.abilityPointsUsed = {}
  o.abilityActive = {}
  --o.abilityPointDuration = {}

	for i = 1, #Abilities do
	  o.abilityPoints[Abilities[i]] = 0
  	o.abilityPointsUsed[Abilities[i]] = o.abilityPoints[Abilities[i]]
  	o.abilityActive[Abilities[i]] = false
	end

	-- Speed abilities
	o.speedRate = self.NormalSpeedRate
	
	return o
end

function Commander.prototype:move(xIncrement, yIncrement)
  self.rotation = math.atan2(xIncrement, -yIncrement)
  self.xIncrement = xIncrement
  self.yIncrement = yIncrement
end

function Commander.prototype:draw()
  -- Draw lasso
  self.lasso:draw()

  -- Draw commander
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 0.25, 0.25, self.offsetX, self.offsetY)
end

function Commander.prototype:update()
  -- Update position
  self.x = self.x + self.xIncrement
  self.y = self.y + self.yIncrement

  -- Update lasso
  self.lasso:setPosition(self.x, self.y)
  self.lasso:update()

  if self.lasso.closed then
    -- Grab new followers

    -- Destroy lasso
    self.lasso:destroy()

    -- Create new lasso
    self.lasso = Lasso:new(self.x, self.y, self.color)
  end
  
  -- Update abilities
  -- reset ability effects
	self.speedRate = self.NormalSpeedRate
  self.color.red = 0
  self.color.green = 0
  self.color.blue = 0
  self.color.alpha = 255
  
  -- apply ability effects if active
  for i = 1, #Abilities do
    local ability = Abilities[i]
    if self.abilityActive[ability] then
      -- player is trying to use the ability
      
      if self.abilityPointsUsed[ability] < self.abilityPoints[ability] then
        self.abilityPointsUsed[ability] = self.abilityPointsUsed[ability] + 1
        -- points were consumed
        -- abilityPointsUsed[ability] = 0
        -- TODO: deactivate ability here for optimization
        self:applyAbility(ability)
      end
    else
      -- player is not trying to use the ability
      
      if (self.abilityPointsUsed[ability] > 0) then
        self.abilityPointsUsed[ability] = self.abilityPointsUsed[ability] - 1
      end
    end
  end
end

function Commander.prototype:gainFollower(follower)
  self.abilityPoints[follower.ability] = self.abilityPoints[follower.ability] + perFollowerAbilityPoints
  table.insert(self.followers, follower)
end

--function Commander.prototype:loseFollowers(followerIndices)
--  for i = 1, #followerIndices do
--    local index = followerIndices[i]
--    local ability = self.followers[index].ability
--    self.abilityPoints[ability] = self.abilityPoints[ability] - perFollowerAbilityPoints
--    table.remove(self.followers, index)
--  end
--end


-- Abilities
function Commander.prototype:applyAbility(ability)
  self.abilityActive[ability] = true
  
  -- apply ability effect
  self.color.red = 255
  self.color.green = 255
  self.color.blue = 255
  self.color.alpha = 255
end

function Commander.prototype:stopAbility(ability)
  self.abilityActive[ability] = false
end


--function Commander.prototype:burst()

