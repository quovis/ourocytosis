Match = {
  prototype = {},
  mt = {}
}

Match.mt.__index = Match.prototype

function Match:new()
  local o = {}
  setmetatable(o, self.mt)

  -- Initialize match

  --o.lazo = Lazo:new()

  return o
end

function Match.prototype:update()
  --self.lazo:update()
end

function Match.prototype:draw()
  --self.lazo:draw()
end
