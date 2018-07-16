--[[
	Creates Handles around all sides of a GUI. 	
	
	As of now, the majority of work here is done through events -
	  This simply creates & interacts with the UI for the Handles.
	
	There are two events to be aware of:
	  UpdateActive (id : String)
	     Will be fired with the ID of the Handle which has been activated.
	     - If the id is nil, this means there is no active Handle.
	
	  UpdateMouseIcon (icon : String)
	     Will be fired with an image to set the mouse icon to.
	     - If the icon is nil, the mouse icon should be reset.
	
	The constructor must be called as:
	  constructor (frame : GuiObject, options : Options)
	    Purpose: Constructs a new Handles object (and adds all handles).
	    Arguments:
	      frame    GuiObject  This is the frame to add Handles to.
	                            Note this works on any GUI object, but suggested 
	                            for a Frame.
	      options  Options    Options to use for the creation of the object.
	                            See OPTIONS, below.
	
	Public Methods:
	  hide ()
	     Hides the handles (while hidden, no interactions can occur).
	  show ()
	     Shows the handles (shown on screen, react to interactions)
	  remove()
	     Destroys the handles & all related members. Note this will not be usable
	       after being removed.
	  getActive () : string
	     Gets the currently active handle. Returns the ID.
	
	OPTIONS:
	  Any of these options can be sent into the constructor. All are optional:
	    size     Integer  The size to use for each Handle. Defaults to 3.
	    bgColor  Color3   The color to use for each Handle. Defaults to a slight orange.
	    bgTrans  Float    Transparency to use for each Handle.
	                        If given, must be between 0 (visible) and 1 (hidden).
	                        Defaults to 0.2.
	    debug    Boolean  If true, debug messages will be logged to the console.
	                        Defaults to false.
--]]


local Handles = { };
local H       = { };

-- Dependencies
local Handle = require(script.Handle);
local Types  = require(script.Parent.Types);

-- Default values, other constants
local handlesFrameName = "ResizeHandlesFrame";
local defaultSize = 3;

local resizeIcons = {
	horizontal = "rbxassetid://1283244444",
	vertical   = "rbxassetid://1283244456",
	diagonalTopLeft = "rbxassetid://1283244442",
	diagonalTopRight = "rbxassetid://1283244443"
};

local mult = 2;

local handleInfo = {
	[Types.Right] = {
		position = UDim2.new (1, defaultSize * -mult, 0, defaultSize * mult),
		size     = UDim2.new (0, defaultSize * mult, 1, defaultSize * -mult * 2),
		img      = resizeIcons.horizontal
	},
	[Types.Left] = {
		position = UDim2.new (0, 0, 0, defaultSize * mult),
		size     = UDim2.new (0, defaultSize * mult, 1, defaultSize * -mult * 2),
		img      = resizeIcons.horizontal
	},
	[Types.Top] = {
		position = UDim2.new (0, defaultSize * mult, 0, 0),
		size     = UDim2.new (1, defaultSize * -mult * 2, 0, defaultSize * mult),
		img      = resizeIcons.vertical
	},
	[Types.Bottom] = {
		position = UDim2.new (0, defaultSize * mult, 1, defaultSize * -mult),
		size     = UDim2.new (1, defaultSize * -mult * 2, 0, defaultSize * mult),
		img      = resizeIcons.vertical
	},
	[Types.TopRight] = {
		position = UDim2.new (1, defaultSize * -mult, 0, 0),
		size     = UDim2.new (0, defaultSize * mult, 0, defaultSize * mult),
		img      = resizeIcons.diagonalTopRight
	},
	[Types.TopLeft] = {
		position = UDim2.new (0, 0, 0, 0),
		size     = UDim2.new (0, defaultSize * mult, 0, defaultSize * mult),
		img      = resizeIcons.diagonalTopLeft
	},
	[Types.BottomRight] = {
		position = UDim2.new (1, defaultSize * -mult, 1, defaultSize * -mult),
		size     = UDim2.new (0, defaultSize * mult, 0, defaultSize * mult),
		img      = resizeIcons.diagonalTopLeft
	},
	[Types.BottomLeft] = {
		position = UDim2.new (0, 0, 1, defaultSize * -mult),
		size     = UDim2.new (0, defaultSize * mult, 0, defaultSize * mult),
		img      = resizeIcons.diagonalTopRight
	}
};

local Horizontal = {Types.Left, Types.Right};
local Vertical   = {Types.Top, Types.Bottom};
local Both       = {Types.TopLeft, Types.TopRight, Types.BottomLeft, Types.BottomRight};


-- Default Values
local axesFromString = {
	xy = {vertical = true, horizontal = true},
	y  = {vertical = true, horizontal = false},
	x  = {vertical = false, horizontal = true}
};

function parseAxes (axes)
	-- 1) If not given, return default
	if (not axes) then
		return {vertical = true, horizontal = true};
	end
	
	-- 2) If it's a table, return the given values
	if (typeof (axes) == "table") then
		if (axes.vertical == nil) then
			axes.vertical = true;
		end
		if (axes.horizontal == nil) then
			axes.horizontal = true;
		end
		return axes;
	end
	
	-- 3) If it's a string, match based on the string
	if (typeof (axes) == "string") then
		local value = axesFromString [axes:lower()];
		if (value) then return value end;
	end
	
	-- 4) If we couldn't find it, return default
	return {vertical = true, horizontal = true};
end
-- *** CONSTRUCTOR *** --
function H.new (frame, options)
	if (not options) then options = { }; end
	options.axes = parseAxes (options.axes);
	
	local handles = setmetatable({
		_mainFrame    = frame,
		_handlesFrame = nil,
		_handleSize   = options.size or defaultSize,
		_bgColor      = options.bgColor or Color3.fromRGB(255, 192, 103),
		_bgTrans      = options.bgTrans or 0.2,
		
		_buttons = { },
		
		_active      = nil,
		_lastHovered = nil,
		
		_isHorizontalVisible = options.axes.horizontal,
		_isVerticalVisible   = options.axes.vertical,
		
		_debug  = options.debug,
		
		UpdateActive    = Instance.new("BindableEvent"),
		UpdateMouseIcon = Instance.new("BindableEvent")
	}, Handles);
	
	handles:_init ();
	return handles;
end

-- *** PUBLIC METHODS *** --
function Handles:hide ()
	self._handlesFrame.Visible = false
end
function Handles:show ()
	self._handlesFrame.Visible = true
end
function Handles:remove ()
	self._handlesFrame:Destroy ();
end
function Handles:getActive ()
	return self._active;
end
function Handles:setActive (id)
	self:_log ("Active set to ", id, " from outside");
	self._active = id;
end

function Handles:setVerticalVisible (isVisible)
	self:_setHandlesVisible (Vertical, isVisible);
	
	self._isVerticalVisible = isVisible;
	self:_updateBothVisibility ();
end
function Handles:setHorizontalVisible (isVisible)
	self:_setHandlesVisible (Horizontal, isVisible);
	
	self._isHorizontalVisible = isVisible;
	self:_updateBothVisibility ();
end

function Handles:isWithinHandle (position)
	local activeHandle = self._lastHovered;
	return activeHandle and activeHandle:contains (position);
end

-- *** PRIVATE METHODS *** --

-- Setting active handle
function Handles:_setActive (id)
	if (self._active) then return end;
	
	self._active = id;
	self.UpdateActive:Fire (id);
	
	self:_log ("Updating active handle: ", id);
end

-- Update mouse icon
function Handles:_updateMouseIcon (image, handle)
	if (image) then 
		self._lastHovered = handle; 
	elseif (handle ~= self._lastHovered) then
		self:_log (handle, " attempted to reset image, but is no longer active.");
		return;
	end
	
	self.UpdateMouseIcon:Fire (image);
	self:_log ("Updating mouse icon: ", image);
end

-- Setting handle visibility
function Handles:_updateBothVisibility ()
	local areBothVisible = self._isVerticalVisible and self._isHorizontalVisible;
	self:_setHandlesVisible (Both, areBothVisible);
end

function Handles:_showHandles (handleIds)
	self:_setHandlesVisible (handleIds, true);
end
function Handles:_hideHandles (handleIds)
	self:_setHandlesVisible (handleIds, false);
end
function Handles:_setHandlesVisible (handleIds, isVisible)
	for _,id in pairs (handleIds) do
		self:_setHandleVisible (id, isVisible);
	end
end
function Handles:_setHandleVisible (id, isVisible)
	local handle = self._buttons [id];
	if (not handle) then
		self:_log ("Could not find handle with ID ", id);
		return;
	end
	
	handle:setVisible(isVisible);
end

-- Main Initialization for Handles object
function Handles:_init ()
	local handlesFrame = self:_initHandlesFrame ();
	
	for id,info in pairs (handleInfo) do
		local handle = self:_initButton (id, info, handlesFrame);
		self._buttons [id] = handle;
	end
	
	self._handlesFrame  = handlesFrame;
	handlesFrame.Parent = self._mainFrame;
	
	self:_initializeVisibleHandles ();
end

-- Initializing visibility of handles
function Handles:_initializeVisibleHandles ()
	self:setVerticalVisible (self._isVerticalVisible);
	self:setHorizontalVisible (self._isHorizontalVisible);
end

-- Initializing the main frame to store Handles
function Handles:_initHandlesFrame ()
	-- Note: Need space for 2 * handlesSize on each axis (Top & Bottom, Left & Right)
	local handlesSize = self._handleSize;
	local size        = UDim2.new (1, handlesSize * mult * 2, 1, handlesSize * mult * 2);
	local pos         = UDim2.new (0, handlesSize * -mult, 0, handlesSize * -mult);
	
	return self:_initFrame (size, pos);
end

function Handles:_initFrame (size, pos)
	local frame    = Instance.new ("Frame");
	
	frame.Size     = size;
	frame.Position = pos;
	frame.Name     = handlesFrameName;
	frame.ZIndex   = 99;
	frame.BackgroundTransparency = 1;
	
	return frame;
end

-- Initializing a single handle
function Handles:_initButton (id, buttonDetails, parent)
	-- Create a new object to store the buttonDetails
	-- So that it doesn't get reset each time
	local newDetails = {
		id = id,
		bgColor = self._bgColor,
		bgTrans = self._bgTrans,
		parent = parent,
		img = buttonDetails.img
	};
	for key,value in pairs (buttonDetails) do
		newDetails [key] = value;
	end
	
	-- Fix the size & position to the user-specified values
	self:_fixSize (newDetails);
	self:_fixPos (newDetails);
	
	self:_log ("After fixing, size: ", newDetails.size, " & pos: ", newDetails.position);

	-- And create the handle
	return self:_createHandle (newDetails);
end
function Handles:_createHandle (details)
	local handle = Handle.new (details);
	self:_addEventHandlers (handle);
		
	self:_log ("Initialized handle ", details.id);
	return handle;
end

-- Fix default size & position for a button
function Handles:_fixSize (details)
	details.size = self:_fix (details.size, defaultSize, self._handleSize);
end
function Handles:_fixPos (details)
	details.position = self:_fix (details.position, defaultSize, self._handleSize);
end
function Handles:_fix (udim2, default, mult)
	-- Note: The Offset values are based on a multiplier.
	--       By taking these multiplier values and multiplying instead by mult,
	--       we can fix them to the given size constraints.
	local fix = function(value)
		return (value / default) * mult;
	end
	
	return UDim2.new (udim2.X.Scale, fix(udim2.X.Offset),
		              udim2.Y.Scale, fix(udim2.Y.Offset)
	);
end

-- Handle events
function Handles:_addEventHandlers (handle)
	self:_on (handle.Deactivated, function(id)
		self:_setActive (nil);
	end)
	self:_on (handle.Activated, function(id) self:_setActive (id); end)
	self:_on (handle.Entered, function(img) self:_updateMouseIcon (img, handle); end)
	self:_on (handle.Left, function() self:_updateMouseIcon (nil, handle); end)
end
function Handles:_on (event, func)
	event.Event:connect (function (...)
		self:_log ("Reacting to event ", event, " with arguments ", ...);
		func (...);
	end);
end

-- Logging
function Handles:_log (...)
	if (self._debug) then
		print (...);
	end
end

Handles.__index = Handles;
return H;