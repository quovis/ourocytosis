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
  
  for i = 0, #Game.players do
    o.commanders[i] = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'))
  end
  
  --o.lazo = Lazo:new()

  return o
end

function Match.prototype:update()
  --self.lazo:update()
  -- Update commander
  for i = 0, #self.commanders do
    self.commanders[i]:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
  end
end

function Match.prototype:draw()
  --self.lazo:draw()
  for i = 0, #self.commanders do
    self.commanders[i]:draw()
  end
end