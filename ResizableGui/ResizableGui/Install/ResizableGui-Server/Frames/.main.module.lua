local Frames = { };
local F      = { };

local Frame  = require (script.FrameData);

function F.new ()
	return setmetatable({
		_frames = { }
	}, Frames);
end

function Frames:get (key)
	if (not self._frames [key]) then
		self._frames [key] = Frame.new (key);
	end
	
	return self._frames [key];
end

function Frames:each (f)
	for _, frame in pairs (self._frames) do
		f (frame);
	end
end

Frames.__index = Frames;
return F;