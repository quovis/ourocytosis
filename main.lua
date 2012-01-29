require "game" 

function love.load()
  love.graphics.setBackgroundColor(54, 172, 248)
  Game:load()
  Game:startMatch()
end

function love.update()
  Game:update()
end

function love.draw()
  Game:draw()
end