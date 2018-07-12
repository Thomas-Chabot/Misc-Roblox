local Saving = { };
local S      = { };

local getScreenSize = require (script.ScreenSize);

-- Server connections
local replStorage      = game:GetService("ReplicatedStorage");
local resizable        = replStorage:WaitForChild ("ResizableGui");
local remoteFuncs      = resizable:WaitForChild ("RemoteFunctions");
local remoteEvents     = resizable:WaitForChild ("RemoteEvents");
local getData          = remoteFuncs:WaitForChild ("GetData");
local setData          = remoteEvents:WaitForChild ("SetData");
local update           = remoteEvents:WaitForChild ("Update");

function generateKey (keyType, frame, id)
	local absSize = getScreenSize()
	return keyType .. " - " .. absSize.X .. "x" .. absSize.Y .. " - " .. id;
end

function S.new (player, frame, options)
	local id = options and options.uniqId;
	assert (id, " Options.uniqId is a required argument.");
	
	local saving = setmetatable({
		_player = player,
		_frame  = frame,
		
		_saveInterval = options.saveInterval,
		
		_posKey  = generateKey("Position", frame, id),
		_sizeKey = generateKey("Size", frame, id)
	}, Saving);
	
	-- Autosave
	if (options.saveInterval) then
		saving:_startAutosave ();
	end
	
	return saving;
end

function Saving:load ()
	local data = self:_getData ();
	self:_set (data, "Size");
	self:_set (data, "Position");
end

function Saving:save ()
	self:_update (true);
end

function Saving:update ()
	self:_update (false);
end

-- Autosave Feature
function Saving:_startAutosave ()
	spawn (function ()
		self:_autosave ();
	end)
end
function Saving:_autosave ()
	while wait (self._saveInterval) do
		self:save();
	end
end

-- Main Method for Saving
function Saving:_update (doSave)
	local sizeVal = self:_get ("Size");
	local posVal  = self:_get ("Position");
	
	local sizeKey = self._sizeKey;
	local posKey  = self._posKey;
	
	self:_updateValue (posKey, posVal);
	self:_updateValue (sizeKey, sizeVal);
	
	if (doSave) then
		self:_setValue (posKey, posVal);
		self:_setValue (sizeKey, sizeVal);
	end
end

-- Frame interactions
function Saving:_set (data, name)
	local value = data [name];
	if (not value) then return end
	
	self._frame [name] = value;
end
function Saving:_get (name)
	return self:_encode (self._frame [name]);
end

-- Get & Set data
function Saving:_getData ()
	local posValue  = self:_getValue (self._posKey);
	local sizeValue = self:_getValue (self._sizeKey);
	
	return {
		Size     = self:_decode (sizeValue),
		Position = self:_decode (posValue)
	}
end

-- Server Interactions
function Saving:_updateValue (key, value)
	update:FireServer (key, value);
end
function Saving:_getValue (key)
	return getData:InvokeServer (key);
end
function Saving:_setValue (key, value)
	-- Note: Setting is ok here, because we want to set size & position
	--       not worrying about what was set before...
	setData:FireServer (key, value);
end


-- Encoding for storage
function Saving:_encode (value)
	return string.format ("%.2f %.2f %.2f %.2f", value.X.Scale, value.X.Offset,
		                                         value.Y.Scale, value.Y.Offset
	);
end
function Saving:_decode (value)
	if (not value) then return nil end
	
	local values = self:_getNumbers (value);
	return UDim2.new (values [1], values [2], values [3], values [4]);
end
function Saving:_getNumbers (value)
	local nums = { };
	for num in string.gmatch (value, "%S+") do
		table.insert (nums, num);
	end
	return nums;
end

Saving.__index = Saving;
return S;