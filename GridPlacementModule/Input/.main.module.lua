local I     = { };

-- ** Game Services ** --
local UserInputService = game:GetService ("UserInputService");

-- ** Module Structure ** --
local main = script.Parent;

-- ** Dependencies ** --
local EventSystem = require (main.EventSystem);
local Screen3D    = require (script.Screen3D);

-- ** Objects ** --
local screen3D = Screen3D.new();

-- ** Constants ** --
local VALID_INPUT_PRESS = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.Touch
};
local VALID_INPUT_MOVEMENT = {
	Enum.UserInputType.MouseMovement,
	Enum.UserInputType.Touch
}

-- ** Constructor ** --
local Input = EventSystem.new();
function I.new ()
	local input = setmetatable ({
		_isButtonPressed = false,
		
		PositionChanged = Instance.new ("BindableEvent"),
		ButtonReleased = Instance.new ("BindableEvent")
	}, Input);
	
	input:_init ();
	return input;
end

-- ** Public Getters ** --
function Input:isButtonPressed ()
	return self._isButtonPressed;
end

-- ** Private Methods ** --
-- Initializes the object
function Input:_init ()
	self:_addEvents ();
end

-- Event Handlers
function Input:_addEvents ()
	-- Note: The _connect method is provided by the EventSystem
	self:_connect (UserInputService.InputBegan, self._onInputBegan);
	self:_connect (UserInputService.InputEnded, self._onInputEnded);
	self:_connect (UserInputService.InputChanged, self._onInputChanged);
end

-- The main three methods
function Input:_onInputBegan (inputObject, gameProcessed)
	if (gameProcessed) then return end
	self:_checkButtonDown (inputObject, true);
end
function Input:_onInputEnded (inputObject, gameProcessed)
	if (gameProcessed) then return end
	self:_checkButtonDown (inputObject, false);
end
function Input:_onInputChanged (inputObject, gameProcessed)
	if (gameProcessed) then return end
	self:_checkMovement (inputObject);
end

-- Input Validation
function Input:_isValidPress (inputObject)
	return self:_isInArray (inputObject.UserInputType, VALID_INPUT_PRESS);
end
function Input:_isValidMovement (inputObject)
	return self:_isInArray (inputObject.UserInputType, VALID_INPUT_MOVEMENT);
end
function Input:_isInArray (value, array)
	-- The main function for validation - checks if a given value appears inside
	--  an array
	for _,element in pairs (array) do
		if (element == value) then
			return true;
		end
	end
	return false;
end

-- Main input pressing, movement nethods
-- Checks if the input matches a button being held down
function Input:_checkButtonDown (inputObject, isDown)
	-- Note here, this will have issues if using both touch & mouse;
	--  That shouldn't be a case, however, & should be fine
	if (self:_isValidPress(inputObject)) then
		self._isButtonPressed = isDown;
		self:_buttonPressed (isDown);
	end
end

-- Checks if the input indicates movement & reacts to that
function Input:_checkMovement (inputObject)
	if (not self:_isValidMovement (inputObject)) then return end
	self:_movement (inputObject);
end

-- Fires off the movement event when the mouse has moved
function Input:_movement (inputObject)
	local position = inputObject.Position;
	local ray3D = screen3D:getScreenRay (position);
	
	self:_fireMovement (ray3D);
end
function Input:_fireMovement (ray3D)
	self.PositionChanged:Fire (ray3D, self._isButtonPressed);
end

-- Reacts to button press
function Input:_buttonPressed (isDown)
	if (not isDown) then return end
	self.ButtonReleased:Fire ();
end

Input.__index = Input;
return I;