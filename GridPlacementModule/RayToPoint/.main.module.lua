local RayToPoint = { };

local MAX_DIST = 5000;

function reconstruct (ray)
	return Ray.new (ray.Origin, ray.Direction * MAX_DIST);
end

-- Given a ray, convert it into some 3D point
function RayToPoint.findPoint (ray, ignoreDescendants)
	local newRay = reconstruct (ray);
	local part,position = workspace:FindPartOnRay (newRay, ignoreDescendants);
	
	return position;
end

return RayToPoint;