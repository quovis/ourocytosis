require "game/joystick"
require "game/match"
require "game/player"
require "game/hud"
require "game/commander"
require "game/follower"

-- The Game object is a singleton
Game = {}

function Game:load()
  self.jss = Joystick:getJoysticks()
end

function Game:addPlayer()
end

function Game:startMatch()
end

-- Callback invoked by Match when once it ends
function Game:matchEnded()
end

function Game:draw()
  self.jss[0]:draw()
end

function Game:update()
  for i = 0, #self.jss do
    self.jss[i]:update()
  end
end
