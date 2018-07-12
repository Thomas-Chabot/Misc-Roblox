local Mouse = { };
local M     = { };

function M.new (player)
	assert (player, " Player is a required argument ");
	
	local mouse = setmetatable({
		_player      = player,
		_mouse       = player:GetMouse(),
		_defaultIcon = ""
	}, Mouse);
	
	mouse:_init ();
	return mouse;
end

function Mouse:setIcon (icon)
	local mouse = self._player:GetMouse ();
	if (not icon) then icon = self._defaultIcon; end
	
	mouse.Icon = icon;
end

function Mouse:_init ()
	local mouse = self._mouse or self._player:GetMouse ();
	self._defaultIcon = mouse.Icon;
end

Mouse.__index = Mouse;
return M;