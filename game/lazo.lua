Lazo = {
  -- How often to insert a new segment
  INSERT_SEGMENT_EVERY = 0.025,
  MAX_LENGTH = 80,

  prototype = {},
  mt = {}
}

Lazo.mt.__index = Lazo.prototype

function Lazo:new()
  local o = {}
  setmetatable(o, self.mt)

  -- The coordinates for the lazo head
  o.x = love.graphics.getWidth() / 2
  o.y = love.graphics.getHeight() / 2

  -- The array of segments
  o.segments = {}

  --
  o.closed = false

  -- When the last segment was added
  o.lastSegmentAt = love.timer.getTime()

  return o
end

function Lazo.prototype:update()
  if not self.closed then
    local currTime = love.timer.getTime()

    -- Check if enough time passed to add a new segment
    -- to the lazo
    if (currTime - self.lastSegmentAt) > Lazo.INSERT_SEGMENT_EVERY then
      self.lastSegmentAt = currTime
      self:insertSegment()
    end
    
    -- If the lazo grows longer than the max length
    -- then cut its tail
    if #self.segments > Lazo.MAX_LENGTH then
      self:shorten(1)
    end
  end

  -- Move lazo head
  self.x = self.x + Game.jss[0].x * 4
  self.y = self.y + Game.jss[0].y * 4
end

function Lazo.prototype:draw()
  -- Draw each segment
  for key, segment in ipairs(self.segments) do
    segment:draw()
  end

  -- Draw the lazo head
  love.graphics.circle('fill', self.x, self.y, 3)
end

function Lazo.prototype:insertSegment()
  local lastSegment = self:getLastSegment()
  local x1, y1

  if lastSegment then
    x1, y1 = lastSegment.x2, lastSegment.y2
  else
    x1 = love.graphics.getWidth() / 2
    y1 = love.graphics.getHeight() / 2
  end

  local newSegment = LazoSegment:new(x1, y1, self.x, self.y)

  -- Check if the new segment intersects with any of
  -- the existing ones
  local maxn = table.maxn(self.segments)
  for key, segment in ipairs(self.segments) do
    if key < maxn and newSegment:checkIntersection(segment) then
      -- Flag the lazo as closed
      self.closed = true

      -- Remove the tail
      self:shorten(key - 2)

      break
    end
  end

  table.insert(self.segments, newSegment)
end

function Lazo.prototype:getLastSegment()
  return self.segments[table.maxn(self.segments)]
end

function Lazo.prototype:shorten(n)
  for i = 0, n do
    table.remove(self.segments, 1)
  end
end

LazoSegment = {
  prototype = {},
  mt = {}
}

LazoSegment.mt.__index = LazoSegment.prototype

function LazoSegment:new(x1, y1, x2, y2)
  local o = {}
  setmetatable(o, self.mt)

  -- 
  o.x1, o.y1 = x1, y1
  o.x2, o.y2 = x2, y2

  return o
end

function LazoSegment.prototype:draw()
  love.graphics.line(self.x1, self.y1, self.x2, self.y2)
end

-- Returns the coordinates of the segment in a new
-- object, with x1 always smaller than x2, and
-- y1 always smaller than y2
function LazoSegment.prototype:normalizedCoords()
  -- Return memoized values if available
  if self._normalizedCoords then
    return self._normalizedCoords
  end

  local coords = {}

  if self.x1 < self.x2 then
    coords.x1 = self.x1
    coords.x2 = self.x2
  else
    coords.x1 = self.x2
    coords.x2 = self.x1
  end

  if self.y1 < self.y2 then
    coords.y1 = self.y1
    coords.y2 = self.y2
  else
    coords.y1 = self.y2
    coords.y2 = self.y1
  end

  -- Memoize the result
  self._normalizedCoords = coords

  return coords
end

-- This could be optimized hardcore if only I could
-- math d:
function LazoSegment.prototype:checkIntersection(other)
  local sc = self:normalizedCoords()
  local oc = other:normalizedCoords()

  local ix = (sc.x1 < oc.x1 and sc.x2 > oc.x1) or (oc.x1 < sc.x1 and oc.x2 > sc.x1)
  local iy = (sc.y1 < oc.y1 and sc.y2 > oc.y1) or (oc.y1 < sc.y1 and oc.y2 > sc.y1)

  return ix and iy
end
