Lazo = {
  prototype = {},
  mt = {}
}

Lazo.mt.__index = Lazo.prototype

function Lazo:new()
  local o = {}
  setmetatable(o, self.mt)

  -- 

  return o
end
