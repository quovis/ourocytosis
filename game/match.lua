Match = {
  prototype = {},
  mt = {}
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)

  -- Initialize match dynamics

  if Game.test.commander then
    o.commanderMaxSpeed = 4.0
    o.commanders = {}
    
    for i = 0, #Game.players do
      o.commanders[i] = Commander:new(200 * i, 200 * i, love.graphics.newImage('assets/beholder.png'))
    end
  end
  
  if Game.test.lasso then
    o.lasso = Lasso:new()
  end

  return o
end

function Match.prototype:update()
  if Game.test.commander then
    -- Update commander
    for i = 0, #self.commanders do
      self.commanders[i]:move(Game.jss[i].x * self.commanderMaxSpeed, Game.jss[i].y * self.commanderMaxSpeed)
    end
  end

  if Game.test.lasso then
    self.lasso:update()
  end
end

function Match.prototype:draw()
  if Game.test.commander then
    for i = 0, #self.commanders do
      self.commanders[i]:draw()
    end
  end

  if Game.test.lasso then
    self.lasso:draw()
  end
end
