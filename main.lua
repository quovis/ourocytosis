require "game" 

function love.load()
  jss = Joystick:getJoysticks()
end

function love.update()
  for i=0,#jss do
    jss[i]:update()
  end
end

function love.draw()
  jss[1]:draw()
end
