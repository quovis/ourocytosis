Player = {
	prototype = {},
	mt = {}
}
Player.mt.__index = Player.prototype


function Player:new()
	local o = {}
	setmetatable(o, self.mt)
	
	-- initialization
	return o
end
