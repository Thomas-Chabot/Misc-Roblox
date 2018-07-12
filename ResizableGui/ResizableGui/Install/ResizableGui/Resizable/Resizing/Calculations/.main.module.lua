local Types = require (script.Parent.Parent.Types);

function calculate (udim2, xOffset, yOffset)
	if (xOffset == nil) then xOffset = udim2.X.Offset; end
	if (yOffset == nil) then yOffset = udim2.Y.Offset; end
	return UDim2.new (udim2.X.Scale, xOffset, udim2.Y.Scale, yOffset)
end

function calculateBySize (frame, position, endPos, minimum, maximum, axis)
	-- First: Calculate the size. The end should be at the new position, so adjust for that
	local newSize = position[axis] - frame.Position[axis].Offset;
	
	-- Make sure within ranges
	newSize = math.max (newSize, minimum[axis]);
	newSize = math.min (newSize, maximum [axis]);
	
	if (axis == 'X') then
		frame.Size = calculate (frame.Size, newSize);
	else
		frame.Size = calculate (frame.Size, nil, newSize);
	end
end

function calculateByPosition (frame, position, endPos, minimum, maximum, axis)
	local startPos = position [axis];
	local endPos   = endPos   [axis].Offset;
	
	-- Make sure it's not past the minimum / maximum ranges
	startPos = math.min (startPos, endPos - minimum[axis]);
	startPos = math.max (startPos, endPos - maximum[axis]);
	
	-- Calculate position & size ...
	--   position changes to position of mouse/touch;
	--   size changes to end - position (whatever size is needed)
	local pos  = startPos;
	local size = endPos - startPos;	
	
	if (axis == 'X') then
		frame.Position = calculate (frame.Position, pos);
		frame.Size     = calculate (frame.Size, size);
	else
		frame.Position = calculate (frame.Position, nil, pos);
		frame.Size     = calculate (frame.Size, nil, size);
	end
end

function resizeRight (...)
	local args = {...};
	table.insert (args, 'X');
	calculateBySize (unpack (args));
end
function resizeLeft (...)
	local args = {...};
	table.insert (args, 'X');
	calculateByPosition(unpack (args))
end
function resizeTop (...)
	local args = {...};
	table.insert (args, 'Y');
	calculateByPosition(unpack (args))
end
function resizeBottom (...)
	local args = {...};
	table.insert (args, 'Y');
	calculateBySize (unpack (args));
end
function resizeTopLeft (...)
	resizeTop (...);
	resizeLeft (...);
end
function resizeTopRight (...)
	resizeTop (...);
	resizeRight (...);
end
function resizeBottomLeft (...)
	resizeBottom (...);
	resizeLeft (...);
end
function resizeBottomRight (...)
	resizeBottom (...);
	resizeRight (...);
end



resizes = {
	[Types.Right] = resizeRight,
	[Types.Left] = resizeLeft,
	[Types.Bottom] = resizeBottom,
	[Types.Top]    = resizeTop,
	[Types.TopLeft] = resizeTopLeft,
	[Types.TopRight] = resizeTopRight,
	[Types.BottomLeft] = resizeBottomLeft,
	[Types.BottomRight] = resizeBottomRight
}

return resizes;