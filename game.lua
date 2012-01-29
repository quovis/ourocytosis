require "game/joystick"
require "game/abilities"
require "game/commander"
require "game/match"
require "game/player"
require "game/hud"
require "game/follower"
require "game/lasso"

-- The Game object is a singleton
Game = {}

function Game:load()
  -- Inititalization
  self.jss = Joystick:getJoysticks()
  self.players = {}
  
  for i = 1, #self.jss do
    self:addPlayer()
  end
  
  -- Start Match
  self:startMatch()
end

function Game:addPlayer()
  table.insert(self.players, Player:new())
end

function Game:startMatch()
  self.match = Match:new()
end

-- Returns the current match
function Game:currentMatch()
  return self.match
end

-- Callback invoked by Match when once it ends
function Game:matchEnded()
end

function Game:update()
  if self.match.finished then
    --print("Match finished!")
  else
    for i = 1, #self.jss do
      if self.jss[i] then
        self.jss[i]:update()
      end
    end
    
    -- Update match
    self.match:update()
  end
end

function Game:draw()
  -- Draw match
  self.match:draw()
end
