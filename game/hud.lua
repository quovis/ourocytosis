Hud = {
  prototype = {},
  mt = {},

  TIMER_WIDTH = 200,
  TIMER_HEIGHT = 15,
  TIMER_TOP = 10,
  TIMER_PADDING = 3
}

Hud.mt.__index = Hud.prototype

function Hud:new(commanders)
  local o = {}
  setmetatable(o, self.mt)
  
  -- Initialization
  o.commanders = commanders

  -- Timer
  o.timerX = love.graphics.getWidth() / 2 - Hud.TIMER_WIDTH / 2
  
  return o
end


function Hud.prototype:draw()
  love.graphics.setColorMode("modulate")
  for i = 1, #self.commanders do
    local commander = self.commanders[i]
    love.graphics.setColor(commander.color)
    love.graphics.print("COMMANDER " .. tostring(i), 10, 10, 0, 1, 1)
    for ab = 1, #Abilities do
      local ability = Abilities[ab]
      local points = commander.abilityPoints[ability]
      local usedPoints = commander.abilityPointsUsed[ability]
      love.graphics.print(ability .. ' : ' .. tostring(usedPoints) .. ' / ' .. tostring(points), i * 100, 10 + 15 * ab, 0, 1, 1)
    end
  end
  love.graphics.setColorMode('replace')

  -- Draw timer
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', self.timerX, Hud.TIMER_TOP, Hud.TIMER_WIDTH, Hud.TIMER_HEIGHT)
  love.graphics.rectangle('fill',
    self.timerX + Hud.TIMER_PADDING,
    Hud.TIMER_TOP + Hud.TIMER_PADDING,
    (Hud.TIMER_WIDTH - Hud.TIMER_PADDING * 2) * (Game:currentMatch().timeRemaining / Match.MATCH_DURATION),
    Hud.TIMER_HEIGHT - Hud.TIMER_PADDING * 2
  )
end
