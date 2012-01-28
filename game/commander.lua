Commander = {
	prototype = {},
	mt = {}
}

Commander.mt.__index = Commander.prototype

function Commander:new(x, y, sprite)
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	o.x, o.y = x, y
	o.sprite = sprite
	
	return o
end

function Commander:draw()
end
