local object = { };

function object:moveTo (object, position)
	if (object:IsA("BasePart")) then
		object.Position = position;
	elseif (object:IsA("Model")) then
		object:MoveTo (position);
	else
		print ("Type not supported: ", object.ClassName);
	end
end

return object;