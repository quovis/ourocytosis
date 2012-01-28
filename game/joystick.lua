Joystick = { x = 0.0, y = 0.0, buttonA = false, buttonB = false, buttonX = false, buttonY = false, buttonStart = false}

function Joystick:new(_id)
  local js = { id = _id }
  setmetatable(js, self)
  self.__index = self
  return js
end

function Joystick:updateAxes()
  if self.id then
    self.x, self.y = love.joystick.getAxes( self.id )
  end
end

function Joystick:update()
  self:updateAxes()
end

function Joystick:getJoysticks()
  local n = love.joystick.getNumJoysticks()
  local jss = {}

  for i=0,n-1 do
    jss[i] = Joystick:new(i)
  end
  
  return jss
end

function Joystick:draw()
  love.graphics.print("Axis X: ", 0,0)
  love.graphics.print(self.x, 100, 0)

  love.graphics.print("Axis Y: ", 0,10)
  love.graphics.print(self.y, 100, 10)

  love.graphics.print("Button A: ", 0,30)
  if self.buttonA then
    love.graphics.print("pressed", 100, 30)
  else
    love.graphics.print("released", 100, 30)
  end

  love.graphics.print("Button B: ", 0,40)
  if self.buttonB then
    love.graphics.print("pressed", 100, 40)
  else
    love.graphics.print("released", 100, 40)
  end

  love.graphics.print("Button X: ", 0,50)
  if self.buttonX then
    love.graphics.print("pressed", 100, 50)
  else
    love.graphics.print("released", 100, 50)
  end

  love.graphics.print("Button Y: ", 0,60)
  if self.buttonY then
    love.graphics.print("pressed", 100, 60)
  else
    love.graphics.print("released", 100, 60)
  end

  love.graphics.print("Start: ", 0,70)
  if self.buttonStart then
    love.graphics.print("pressed", 100, 70)
  else
    love.graphics.print("released", 100, 70)
  end
end


function love.joystickpressed( joystick, button )
  if button == 0 then
    Game.jss[joystick].buttonA = true
  end

  if button == 1 then
    Game.jss[joystick].buttonB = true
  end

  if button == 2 then
    Game.jss[joystick].buttonX = true
  end

  if button == 3 then
    Game.jss[joystick].buttonY = true
  end

  if button == 7 then
    Game.jss[joystick].buttonStart = true
  end
end

function love.joystickreleased( joystick, button )
  if button == 0 then
    Game.jss[joystick].buttonA = false
  end

  if button == 1 then
    Game.jss[joystick].buttonB = false 
  end

  if button == 2 then
    Game.jss[joystick].buttonX = false 
  end

  if button == 3 then
    Game.jss[joystick].buttonY =  false
  end

  if button == 7 then
    Game.jss[joystick].buttonStart =  false
  end
end
