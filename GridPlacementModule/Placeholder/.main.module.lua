local Placeholder = { };
local P           = { };

-- ** Structure ** --
local main = script.Parent;

-- ** Dependencies ** --
local object = require (main.Object);

-- ** Constructor ** --
function P.new (transparency)
	return setmetatable ({
		_object = nil,
		_placeholder = nil,
		
		_transparency = transparency
	}, Placeholder);
end

-- ** Public Methods ** --
function Placeholder:create (object)
	self._object = object;
end
function Placeholder:remove ()
	if (not self._placeholder) then return end

	self._placeholder:Destroy()
	self._placeholder = nil;
end

function Placeholder:get ()
	if (self._placeholder) then return self._placeholder; end

	local placeholder = self:_make ();
	self._placeholder = placeholder;
	
	return placeholder;
end

function Placeholder:moveTo (position)
	print ("Moving the placeholder to ", position);
	
	object:moveTo (self._placeholder, position);
end

-- ** Private Methods ** --
-- Creates the placeholder
function Placeholder:_make ()
	local p  = self._object:Clone ();
	p.Parent = workspace;

	self:_add (p);
	return p;
end
function Placeholder:_add (placeholder)
	local descendants = placeholder:GetDescendants();
	table.insert (descendants, placeholder);
	
	for _,obj in pairs (descendants) do
		if (obj:IsA("BasePart")) then
			obj.Anchored = true;
			obj.Transparency = self._transparency;
		end
	end
end

Placeholder.__index = Placeholder;
return P;