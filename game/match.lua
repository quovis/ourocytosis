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
  o.followersCount = 50;
  
	o.followers = {}
	
  for i = 1, #Game.players do
    local commander = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'), CommanderColors[i+1])
    
    o.followers[i] = {}
    -- Create followers
    local ability = Abilities[i]
    for j = 1, o.followersCount do
      o.followers[i][j] = Follower:new(commander, ability)
    end
    
    commander:gainFollowers(o.followers[i])
    o.commanders[i] = commander
  end
  
  if Game.test.lasso then
    o.lasso = Lasso:new()
  end
  
  -- Initialize hud
  o.hud = Hud:new(o.commanders)
  
  return o
end

function Match.prototype:update()
  if Game.test.commander then
    
    -- Remove random followers
    if (math.random(0,100) < 20 and #self.commanders[1].followers > 0) then
      local lostFollowers = {1}
      
      self.commanders[1]:loseFollowers(lostFollowers)
    end
    
    -- Update abilities
    for i = 1, #Game.jss do
      local js = Game.jss[i]
      if (js.buttonA) then
        self.commanders[1]:applyAbility(Abilities[1])
      else
        self.commanders[1]:stopAbility(Abilities[1])
      end
    end
    
    -- Update commander
    for i = 1, #self.commanders do
      local commander = self.commanders[i]
      commander:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
      commander:update()
      for j = 1, #commander.followers do
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
    for i = 1, #self.commanders do
      local commander = self.commanders[i]
      commander:draw()
      for j = 1, #commander.followers do
        commander.followers[j]:draw()
      end
    end
  end

  if Game.test.lasso then
    -- Draw lasso
    self.lasso:draw()
  end
  
  -- Draw hud
  self.hud:draw()
end
