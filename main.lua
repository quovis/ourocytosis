require "game" 

function love.load()
  Game:load()
  
  Game:startMatch()
end

function love.update()
  Game:update()
end

function love.draw()
  Game:draw()
end