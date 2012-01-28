Commander = {
	prototype = {},
	mt = {}
}
Commander.mt.__index = Commander.prototype


function Commander:new(_x, _y, _sprite)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.x, o.y = _x, _y
	o.sprite = _sprite
	
	return o
end


function Commander:draw()
	-- love.graphics.draw( self._sprite, self._x, self._y, , self._sy, self._ox, oy )
end
