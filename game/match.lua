CommanderColors = {
  { 62, 105, 184, 255 }, -- blue
  { 209, 217, 96, 255 }, -- green
  { 248, 208, 25, 255 }, -- yellow
  { 203, 91, 45, 255 } -- red
}

Match = {
  prototype = {},
  mt = {},

  MATCH_DURATION = 60 * 2,

  BackgroundMusic = love.audio.newSource( "assets/base.ogg", 'static')
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)

  -- Time
  o.timeRemaining = Match.MATCH_DURATION
  o.finished = false
  
  -- Initialize match
  -- Dynamics
  o.commanderMaxSpeed = 4.0
  o.commanders = {}

  o.followersCount = 250;
  
	o.followers = {}
	
  for i = 1, #Game.players do
    local commander = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'), CommanderColors[i])
    
    -- Create followers
    local ability = Abilities[i]
    for j = 1, o.followersCount do
      local follower = Follower:new(commander, ability)
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
  self.timeRemaining = self.timeRemaining - love.timer.getDelta()

  if self.timeRemaining <= 0 then
    self.timeRemaining = 0
    self.finished = true
    return
  end
  
  Follower:calculatePartitionsWeightCenters(self.followers)
  
  -- Remove random followers
  -- if (math.random(0,100) < 20 and #self.commanders[1].followers > 0) then
    -- local lostFollowers = {1}
    -- self.commanders[1]:loseFollowers(lostFollowers)
  -- end
  
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

function Match.prototype:draw()
  -- Draw followers
  for i = 1, #self.followers do
    self.followers[i]:draw()
  end
  
  -- Draw commanders
  for i = 1, #self.commanders do
    self.commanders[i]:draw()
  end
  
  -- Draw hud
  self.hud:draw()
end
