Commander = {
	local x
	local y
	local sprite
}


function Commander:new(_x, _y, _sprite)
	local o = {x = _x, y = _y, sprite = _sprite}
	setmetatable(o, self)
	self.__index = self
	return o
end


function Commander:draw()
end
