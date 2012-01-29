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
    love.graphics.setColor(commander.color.red, commander.color.green, commander.color.blue, commander.color.alpha)
    love.graphics.print("COMMANDER " .. tostring(i), 10, 10, 0, 1, 1)
  end
  love.graphics.setColorMode('replace')
end
