CommanderColors = {
  {red = 62, green = 105, blue = 184, alpha = 255}, -- blue
  {red = 209, green = 217, blue = 96, alpha = 255}, -- green
  {red = 248, green = 208, blue = 25, alpha = 255}, -- yellow
  {red = 203, green = 91, blue = 45, alpha = 255} -- red
}


Match = {
  prototype = {},
  mt = {}
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)

  -- Initialize match
  -- Dynamics
  o.commanderMaxSpeed = 4.0
  o.commanders = {}
  o.followersCount = 500;
  
	o.followers = {}

  for i = 0, #Game.players do
    local commander = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'), CommanderColors[i+1])
    

    -- Create followers
    local ability = Abilities[i + 1]
    commander.followers = {}
    for j = 0, o.followersCount - 1 do
      local follower = Follower:new(commander, ability) 
      commander.followers[j] = follower
      table.insert(o.followers, follower)
    end
    
    o.commanders[i] = commander
  end
 
  -- Create Screen Partitions to handle followers calculations
  Follower:initializePartitions()

  if Game.test.lasso then
    o.lasso = Lasso:new()
  end

  return o
end

function Match.prototype:update()

  Follower:calculatePartitionsWeightCenters(self.followers)

  if Game.test.commander then
    -- Update commander
    for i = 0, #self.commanders do
      local commander = self.commanders[i]
      commander:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
      for j = 0, #commander.followers do
        commander.followers[j]:update()
      end
    end
  end

  if Game.test.lasso then
    -- Update lasso
    self.lasso:update()
  end
end

function Match.prototype:draw()
  if Game.test.commander then
    -- Draw commander
    for i = 0, #self.commanders do
      local commander = self.commanders[i]
      commander:draw()
      for j = 0, #commander.followers do
        commander.followers[j]:draw()
      end
    end
  end

  if Game.test.lasso then
    -- Draw lasso
    self.lasso:draw()
  end
end
