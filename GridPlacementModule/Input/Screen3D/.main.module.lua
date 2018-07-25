local Screen3D = { };
local S3D      = { };

-- ** Constructor ** --
function S3D.new ()
	return setmetatable ({
		_player = game.Players.LocalPlayer,
		_camera = workspace.CurrentCamera
	}, Screen3D);
end

-- ** Public Methods ** --
function Screen3D:getScreenRay (position)
	return self:_getScreenCoords (position.X, position.Y);
end

-- ** Private Methods ** --
-- Converts the 2D coordinates to a 3D Ray
function Screen3D:_getScreenCoords (xCoord, yCoord)
	return self._camera:ScreenPointToRay (xCoord, yCoord);
end

Screen3D.__index = Screen3D;
return S3D;