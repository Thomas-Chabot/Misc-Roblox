local EventSystem = { };
local ES = { };

-- ** Game Structure ** --
local classes = script.Parent;

-- ** Constructor ** --
function ES.new ()
	return setmetatable ({
		_events = { }
	}, EventSystem);
end

-- ** Public Methods ** --
function EventSystem:remove ()
	self:_disconnectAllEvents();
end

-- ** Protected Methods ** --
-- Connects an event to a method
function EventSystem:_connect (evt, method)
	-- Trying to fire off a BindableEvent?
	if (typeof (method) == "Instance") then
		-- In this case, method should just be to fire off the event
		local event = method;
		method = function (_, ...) event:Fire (...); end
	end
	
	local connection = evt:connect (function (...)
		method (self, ...);
	end)
	
	table.insert (self._events, connection);
end

-- Connect to bindable function
function EventSystem:_connectFunction (func, method)
	function func.OnInvoke (...)
		return method (self, ...);
	end
end

-- Remove all connections
function EventSystem:_disconnectAllEvents ()
	for _,connection in pairs (self._events) do
		connection:disconnect ();
	end
end


EventSystem.__index = EventSystem;
return ES;