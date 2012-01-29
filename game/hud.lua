Hud = {
  prototype = {},
  mt = {}
}

Hud.mt.__index = Hud.prototype

function Hud:new(commanders)
  local o = {}
  setmetatable(o, self.mt)
  
  -- Initialization
  o.commanders = commanders
  
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
end
