Match = {
  prototype = {},
  mt = {}
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)

  -- Initialize match

  return o
end
