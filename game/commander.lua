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

function Commander.prototype:move(dx, dy)
  --if dx > 0.2 or dx < -0.2 or dy > 0.2 and dy < -0.2 then
    self.rotation = math.atan2(dx, -dy)
    self.dx, self.dy = dx, dy
  --end
end

function Commander.prototype:draw()
  -- Draw lasso
  self.lasso:draw()

  -- Draw commander
  love.graphics.setColorMode('replace')
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 0.25, 0.25, self.offsetX, self.offsetY)
end

function Commander.prototype:update()
  -- Update position
  self.x = self.x + self.dx
  self.y = self.y + self.dy

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

