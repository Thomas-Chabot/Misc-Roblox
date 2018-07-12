local Input = { };
local I     = { };

local UserInputService = game:GetService("UserInputService");

function I.new ()
	local input = setmetatable({
		_events = { },
		
		Dragged    = Instance.new("BindableEvent"),
		ButtonUp   = Instance.new("BindableEvent"),
		MouseMoved = Instance.new("BindableEvent")
	}, Input);
	
	input:_init ();
	return input;
end

-- *** PUBLIC METHODS *** --
function Input:remove ()
	for _,event in pairs (self._events) do
		event:disconnect ();
	end
	
	self._events = { };
end

-- *** PRIVATE METHODS *** --
-- Initialization
function Input:_init ()
	self:_listenForEvents ();
end

-- Initialize Events
function Input:_listenForEvents ()
	local e1 = UserInputService.InputBegan:connect (function (input, gameProcessed)
	--	if (gameProcessed) then return end
		self:_checkDown (input, true);
	end)
	local e2 = UserInputService.InputEnded:connect (function (input, gameProcessed)
	--	if (gameProcessed) then return end
		self:_checkDown (input, false);
	end)
	local e3 = UserInputService.InputChanged:connect (function (input, gameProcessed)
	--	if (gameProcessed) then return end
		self:_checkMouseMoved (input);
	end);
	local e4 = UserInputService.TouchMoved:connect (function (input, gameProcessed)
	--	if (gameProcessed) then return end
		self:_checkMouseMoved (input, true);
	end)
	
	self._events = {e1, e2, e3};
end

-- Event Handlers
function Input:_checkDown (userInput, isDown)
	if (not self:_isDown (userInput)) then return end
	
	self._isMouseDown = isDown;
	if (not isDown) then
		self.ButtonUp:Fire ();
	end
end

function Input:_checkMouseMoved (userInput, isTouch)
	if (not isTouch and not self:_isMovement (userInput)) then return end;
	
	if (not self._isMouseDown) then
		self.MouseMoved:Fire (userInput.Position);	
	else
		self.Dragged:Fire (userInput.Position, isTouch);
	end;
end

-- Check if input is of correct types
function Input:_isMovement (input)
	return --input.UserInputType == Enum.UserInputType.Touch or
	       input.UserInputType == Enum.UserInputType.MouseMovement;
end
function Input:_isDown (input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or
	       input.UserInputType == Enum.UserInputType.Touch;
end

Input.__index = Input;
return I;