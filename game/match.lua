CommanderColors = {
  { 62, 105, 184, 255 }, -- blue
  { 209, 217, 96, 255 }, -- green
  { 248, 208, 25, 255 }, -- yellow
  { 203, 91, 45, 255 } -- red
}

Match = {
  prototype = {},
  mt = {},
  BackgroundMusic = love.audio.newSource( "assets/base.ogg", 'static')
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)
  
  -- Initialize match
  -- Dynamics
  o.commanderMaxSpeed = 4.0
  o.commanders = {}
  
  o.followersCount = 100;
  
	o.followers = {}
	
  for i = 1, #Game.players do
    local commander = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'), CommanderColors[i])
    
    -- Create followers
    local ability = Abilities[i]
    for j = 1, o.followersCount do
      -- TODO: change this
      local follower = Follower:new(commander, Abilities[math.random(1,4)])
      --local follower = Follower:new(commander, ability)
      commander:gainFollower(follower)
      table.insert(o.followers, follower)
    end
    
    -- commander:gainFollowers(o.followers[i])
    o.commanders[i] = commander
  end
  
  -- Create Screen Partitions to handle followers calculations
  Follower:initializePartitions()
  
  -- Initialize hud
  o.hud = Hud:new(o.commanders)
  
  -- Start music
  Match.BackgroundMusic:setLooping(true)
  Match.BackgroundMusic:play()
  return o
end

function Match.prototype:update()
  Follower:calculatePartitionsWeightCenters(self.followers)
  
  -- Remove random followers
  --if (math.random(0,100) < 5 and #self.commanders[1].followers > 0) then
    --local lostFollowers = {1}
    --self.commanders[1]:loseFollowers(lostFollowers)
  --end
  
  -- Update commander
  for i = 1, #self.commanders do
    local commander = self.commanders[i]
    commander:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
    
    -- Update abilities from joystick
    local js = Game.jss[i]
    if (js.buttonA) then
      self.commanders[i]:applyAbility(Abilities[1])
    else
      self.commanders[i]:stopAbility(Abilities[1])
    end
    if (js.buttonB) then
      self.commanders[i]:applyAbility(Abilities[2])
    else
      self.commanders[i]:stopAbility(Abilities[2])
    end
    if (js.buttonX) then
      self.commanders[i]:applyAbility(Abilities[3])
    else
      self.commanders[i]:stopAbility(Abilities[3])
    end
    if (js.buttonY) then
      self.commanders[i]:applyAbility(Abilities[4])
    else
      self.commanders[i]:stopAbility(Abilities[4])
    end
    
    commander:update()
    for j = 1, #commander.followers do
      commander.followers[j]:update()
    end
  end
end

function Match.prototype:draw()
  -- Draw followers
  --for i = 1, #self.followers do
    --self.followers[i]:draw()
  --end
  
  -- Draw commanders
  for i = 1, #self.commanders do
    self.commanders[i]:draw()
    -- TODO: remove this, for testing abilities
    local c = self.commanders[i]
    for j = 1, #c.followers do
      c.followers[j]:draw()
    end
  end
  
  -- Draw hud
  self.hud:draw()
end
