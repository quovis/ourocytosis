Commander = {
	prototype = {},
	mt = {}
}

Commander.mt.__index = Commander.prototype

function Commander:new(x, y, sprite, color, followers)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.x, o.y = x, y
	o.rotation = 0
	o.sprite = sprite
	o.offsetX = sprite:getWidth() / 2
	o.offsetY = sprite:getHeight() / 2
	o.color = color
	o.followers = nil
  o.xIncrement = 0
  o.yIncrement = 0

  -- Initialize lasso
  o.lasso = Lasso:new(x, y, color)
	
	return o
end

function Commander.prototype:move(xIncrement, yIncrement)
  self.rotation = math.atan2(xIncrement, -yIncrement)
  self.xIncrement = xIncrement
  self.yIncrement = yIncrement
end

function Commander.prototype:update()
  self.x = self.x + self.xIncrement
  self.y = self.y + self.yIncrement

  self.lasso:setPosition(self.x, self.y)
  self.lasso:update()

  if self.lasso.closed then
    -- Grab new followers

    -- Destroy lasso
    self.lasso:destroy()

    -- Create new lasso
    self.lasso = Lasso:new(self.x, self.y, self.color)
  end
end

function Commander.prototype:draw()
  -- Draw lasso
  self.lasso:draw()

  -- Draw commander
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 0.25, 0.25, self.offsetX, self.offsetY)
end
