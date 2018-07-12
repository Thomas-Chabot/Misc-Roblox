local FrameData = { };
local FD        = { };

function FD.new (key)
	return setmetatable({
		key = key
	}, FrameData);
end

function FrameData:set (value)
	self.value = value;
end

FrameData.__index = FrameData;
return FD;