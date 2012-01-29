Lasso = {
  prototype = {},
  mt = {},

  -- Constants:

  -- How often to insert a new segment
  INSERT_SEGMENT_EVERY = 0.05,

  -- The max length of the lasso
  MAX_LENGTH = 60,

  -- The width of each segment when drawing
  MAX_SEGMENT_WIDTH = 10
}

Lasso.mt.__index = Lasso.prototype

function Lasso:new(x, y, color)
  local o = {}
  setmetatable(o, self.mt)

  -- The coordinates for the Lasso head
  o.xi, o.x = x, x
  o.yi, o.y = y, y

  -- The lasso color
  o.color = color

  -- The array of segments
  o.segments = {}

  --
  o.closed = false

  -- When the last segment was added
  o.lastSegmentAt = love.timer.getTime()

  return o
end

function Lasso.prototype:setPosition(x, y)
  self.x = x
  self.y = y
end

function Lasso.prototype:update()
  if not self.closed then
    local currTime = love.timer.getTime()

    -- Check if enough time passed to add a new segment
    -- to the Lasso
    if (currTime - self.lastSegmentAt) > Lasso.INSERT_SEGMENT_EVERY then
      self.lastSegmentAt = currTime
      self:insertSegment()
    end
    
    -- If the Lasso grows longer than the max length
    -- then cut its tail
    if #self.segments > Lasso.MAX_LENGTH then
      self:shorten(1)
    end
  end
end

function Lasso.prototype:draw()
  -- Draw each segment
  for i = 1, #self.segments do
    local s = self.segments[i]

    local w = Lasso.MAX_SEGMENT_WIDTH * (i / #self.segments)

    love.graphics.setColorMode('modulate')

    -- Thick colored line
    love.graphics.setLineWidth(w)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 100)
    love.graphics.line(s.x1, s.y1, s.x2, s.y2)

    -- Thin, white-ish line
    love.graphics.setLineWidth(w / 2)
    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.line(s.x1, s.y1, s.x2, s.y2)

    -- Center, white line
    love.graphics.setLineWidth(w / 4)
    love.graphics.setColor(255, 255, 255, 200)
    love.graphics.line(s.x1, s.y1, s.x2, s.y2)

    -- Reset draw settings
    --love.graphics.reset()
  end
end

function Lasso.prototype:destroy()
  self:shorten(#self.segments)
end

function Lasso.prototype:insertSegment()
  local lastSegment = self:getLastSegment()
  local x1, y1

  if lastSegment then
    x1, y1 = lastSegment.x2, lastSegment.y2
  else
    x1 = self.xi
    y1 = self.yi
  end

  local newSegment = LassoSegment:new(x1, y1, self.x, self.y)

  -- Check if the new segment intersects with any of
  -- the existing ones
  local intersection
  for i = 1, #self.segments do

    -- Avoid checking intersection with the last segment
    -- (the one closest to the head) or we'd end up
    -- closing the lasso on the first move
    if i == #self.segments then
      break
    end

    intersection = newSegment:checkIntersection(self.segments[i])

    if intersection then
      -- Flag the Lasso as closed
      self.closed = true

      -- Remove the tail
      self:shorten(i - 2)

      -- Cut the intersecting segments by the intersecting
      -- point
      newSegment.x2 = intersection.x
      newSegment.y2 = intersection.y

      self.segments[1].x1 = intersection.x
      self.segments[1].y1 = intersection.y

      break
    end
  end

  table.insert(self.segments, newSegment)
end

function Lasso.prototype:getLastSegment()
  return self.segments[table.maxn(self.segments)]
end

function Lasso.prototype:shorten(n)
  for i = 1, n do
    table.remove(self.segments, 1)
  end
end

-- Get the bounding box for the Lasso
function Lasso.prototype:getBoundingBox()
  if self._boundingBox then
    return self._boundingBox
  end

  local coords = self.segments[1]:normalizedCoords()

  for i = 1, #self.segments do
    local nCoords = self.segments[i]:normalizedCoords()

    if nCoords.x1 < coords.x1 then
      coords.x1 = nCoords.x1
    end

    if nCoords.x2 > coords.x2 then
      coords.x2 = nCoords.x2
    end

    if nCoords.y1 < coords.y1 then
      coords.y1 = nCoords.y1
    end

    if nCoords.y2 > coords.y2 then
      coords.y2 = nCoords.y2
    end
  end

  if self.closed then
    self._boundingBox = coords
  end

  return coords
end

-- Returns whether a point is inside the Lasso
-- closure or not
function Lasso.prototype:isInside(x, y)
  local bBox = self:getBoundingBox()

  -- Check if we're inside the bounding box first
  -- to avoid unnecessary intersection checks
  if x < bBox.x1 or x > bBox.x2 or y < bBox.y1 or y > bBox.y2 then
    return false
  end

  -- Create a dummy segment to check intersections
  local dummySegment = LassoSegment:new(bBox.x1, y, x, y)
  local iCount = 0

  for i = 1, #self.segments do
    if self.segments[i]:checkIntersection(dummySegment) then
      iCount = iCount + 1
    end
  end

  return (iCount % 2) == 1
end

LassoSegment = {
  prototype = {},
  mt = {}
}

LassoSegment.mt.__index = LassoSegment.prototype

function LassoSegment:new(x1, y1, x2, y2)
  local o = {}
  setmetatable(o, self.mt)

  -- Initialize coordinates
  o.x1, o.y1 = x1, y1
  o.x2, o.y2 = x2, y2

  return o
end

--function LassoSegment.prototype:draw()
--  love.graphics.line(self.x1, self.y1, self.x2, self.y2)
--end

-- Returns the coordinates of the segment in a new
-- object, with x1 always smaller than x2, and
-- y1 always smaller than y2
function LassoSegment.prototype:normalizedCoords()
  -- Return memoized values if available
  if self._normalizedCoords then
    return self._normalizedCoords
  end

  local coords = {
    x1 = math.min(self.x1, self.x2),
    x2 = math.max(self.x1, self.x2),
    y1 = math.min(self.y1, self.y2),
    y2 = math.max(self.y1, self.y2)
  }

  -- Memoize the result
  self._normalizedCoords = coords

  return coords
end

-- I can't math, so here's a port of some implementation
-- in Java
function LassoSegment.prototype:checkIntersection(other)
  local d = (self.x1 - self.x2) * (other.y1 - other.y2) - (self.y1 - self.y2) * (other.x1 - other.x2)

  if d == 0 then
    return false
  end

  local t1 = (self.x1 * self.y2 - self.y1 * self.x2)
  local t2 = (other.x1 * other.y2 - other.y1 * other.x2)

  local xi = (
    (other.x1 - other.x2) * t1 -
    (self.x1 - self.x2) * t2
  ) / d

  local yi = (
    (other.y1 - other.y2) * t1 -
    (self.y1 - self.y2) * t2
  ) / d

  if self.x1 == self.x2 or other.x1 == other.x2 then
    if yi < math.min(self.y1, self.y2) or yi > math.max(self.y1, self.y2) then
      return false
    end

    if yi < math.min(other.y1, other.y2) or yi > math.max(other.y1, other.y2) then
      return false
    end
  end

  if xi < math.min(self.x1, self.x2) or xi > math.max(self.x1, self.x2) then
    return false
  end

  if xi < math.min(other.x1, other.x2) or xi > math.max(other.x1, other.x2) then
    return false
  end

  return { x = xi, y = yi }
end
