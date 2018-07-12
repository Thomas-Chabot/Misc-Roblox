local Resizing = { };
local R        = { };

local Types = require (script.Parent.Types);
local calculations = require (script.Calculations);

-- Helper method ... calculate the value of {X, Y} given a UDim2
function calculatePair (frame, udim2)
	local parentSize = frame and frame.Parent and frame.Parent.AbsoluteSize;
	assert (parentSize, " Parent not found. ");
	
	return {
		X = parentSize.X * udim2.X.Scale + udim2.X.Offset,
		Y = parentSize.Y * udim2.Y.Scale + udim2.Y.Offset
	};
end

-- *** Constructor *** --
function R.new (frame, options)
	if (not options) then options = { }; end
	
	if (not options.minimumSize) then
		options.minimumSize = UDim2.new (0.1, 0, 0.1, 0);
	end
	
	if (not options.maximumSize) then
		options.maximumSize = UDim2.new (1, 0, 1, 0);
	end
	
	local min = calculatePair (frame, options.minimumSize);
	local max = calculatePair (frame, options.maximumSize);
	
	local resizing = setmetatable({
		_frame = frame,
		_minimumSize = min,
		_maximumSize = max,
		_updating    = false
	}, Resizing);
	
	resizing:_init ();
	
	return resizing;
end

-- *** Public Methods *** --
function Resizing:update (position, active)
	if (not active) then return end
	if (not calculations [active]) then print(active, " not found"); return; end
	
	--if (self._updating) then return end
	--self._updating = true;
	if (active ~= self._lastActive) then
		self._lastActive = active;
		self._endPos = self._frame.Position + self._frame.Size;
	end
	
	calculations [active] (self._frame, position, self._endPos, self._minimumSize, self._maximumSize);
	--wait(0.1);
	--self._updating = false;
end

-- *** Private Methods *** --
function Resizing:_init ()
	local fr = self._frame;
	
	fr.Position = UDim2.new (0, fr.AbsolutePosition.X, 0, fr.AbsolutePosition.Y);
	fr.Size     = UDim2.new (0, fr.AbsoluteSize.X, 0, fr.AbsoluteSize.Y);
	fr.SizeConstraint = Enum.SizeConstraint.RelativeXY;
end

Resizing.__index = Resizing;
return R;