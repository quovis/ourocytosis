CommanderColors = {
  { 62, 105, 184, 255 }, -- blue
  { 209, 217, 96, 255 }, -- green
  { 248, 208, 25, 255 }, -- yellow
  { 203, 91, 45, 255 } -- red
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

  o.followersCount = 250;
  
	o.followers = {}

  for i = 0, #Game.players do
    local commander = Commander:new(200 * (i + 1), 200 * (i + 1), love.graphics.newImage('assets/beholder.png'), CommanderColors[i+1])

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

  return o
end

function Match.prototype:update()
  Follower:calculatePartitionsWeightCenters(self.followers)

  -- Update commander
  for i = 0, #self.commanders do
    local commander = self.commanders[i]

    commander:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
    commander:update()

    for j = 0, #commander.followers do
      commander.followers[j]:update()
    end
  end
end

function Match.prototype:draw()
  -- Draw followers
  for i = 0, #self.commanders do
    local commander = self.commanders[i]
    for j = 0, #commander.followers do
      commander.followers[j]:draw()
    end
  end

  -- Draw commanders
  for i = 0, #self.commanders do
    local commander = self.commanders[i]
    commander:draw()
  end
end
