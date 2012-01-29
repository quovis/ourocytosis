require "game/joystick"
require "game/commander"
require "game/abilities"
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
  
  for i = 0, #self.jss do
    self:addPlayer()
  end
  
  -- Start Match
  self:startMatch()
end

function Game:addPlayer()
  if self.players[0] == nil then
    self.players[#self.players] = Player:new()
  else
    self.players[#self.players + 1] = Player:new()
  end
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
  for i = 0, #self.jss do
    if self.jss[i] then
      self.jss[i]:update()
    end
  end

  -- Update match
  self.match:update()
end

function Game:draw()
  if self.jss[0] then
    self.jss[0]:draw()
  end

    -- Draw match
  self.match:draw()
end
