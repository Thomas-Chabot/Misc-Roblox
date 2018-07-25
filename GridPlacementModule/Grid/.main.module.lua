local Grid = { };
local G    = { };

-- ** Constructor ** --
function G.new (constraints, snap)
	return setmetatable ({
		_gridSize = constraints,
		_gridSnap = snap
	}, Grid);
end

-- ** Public Methods ** --
function Grid:getSnapped (position)
	if (not self:_isValid (position)) then return nil end
	return self:_snap (position);
end

-- ** Private Methods ** --
-- Check if a position is valid
function Grid:_isValid (position)
	local min = self._gridSize.min;
	local max = self._gridSize.max;
	
	local _valid = function (x, min, max)
		return (x >= min and x <= max);
	end
	
	return _valid (position.X, min.X, max.X) and
	       _valid (position.Z, min.Y, max.Y);
end

-- Snap to a point
function Grid:_snap (position)
	local snap = function(x, to)
		return math.floor ((x + to/2) / to) * to;
	end
		
	return Vector3.new (
		snap (position.X, self._gridSnap.X),
		position.Y,
		snap (position.Z, self._gridSnap.Y)
	);
end

Grid.__index = Grid;
return G;