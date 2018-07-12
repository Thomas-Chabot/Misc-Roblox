--[[
	Creates a border around a given GUI, allowing the GUI to be resized.
	  Note this should be used on the main GUI, as it will have unexpected results
	  on a child (eg. a frame inside another frame).
	
	Documentation:
	  Constructor
	      Arguments:
	        frame    GuiObject  The main frame to be resizable
	        options  Options    Various options to provide for the resizing.
	                              Seealso OPTIONS, below.
	
	  Options
	    These are various options that can be sent into the constructor.
		[O]  uniqId       String   A unique ID to be used with the Gui. Data will be saved
		                             under the given ID. This should stay the same across
		                             servers & versions.
	    [O]  minimumSize  UDim2    The minimum size that the Frame can be resized to.
	                                 Defaults to {0.1, 0}, {0.1, 0}
	    [O]  maximumSize  UDim2    The maximum size that the Frame can be resized to.
	                                 Defaults to {1, 0}, {1, 0}
	    [O]  size         Integer  The size to allow for each border.
	                                 A larger size allows for more room for the resize
	                                   to react. Defaults to 3.
	    [O]  bgColor      Color3   The color to use for the borders. Defaults to orange-ish.
	    [O]  bgTrans      Number   The transparency to use for each border. Defaults to 0.2.
	 	[O]  axes         String   The Axes to allow resizing on. Possible values:
	                                 XY   Allow resizing horizontally & vertically
	                                 X    Allow resizing horizontally, not vertically
	                                 Y    Allow resizing vertically, not horizontally
	                               Defaults to XY (both).
		[O] saveInterval  Integer  Seconds between saving GUI data. By default, only saves
		                             when player leaves.
	
	    Note, any options listed as [R] are required. Options listed as [O] are optional.
	
	  Methods:
	      remove ()
	        Destroys the Resizable, so the GUI can no longer be resized.
	      hide ()
	        Hides the Resizable, so the GUI will not be resized (can be shown later).
	      show ()
	        Re-adds hidden Resizable elements, so the GUI can be resized.	
	      setVerticallyResizable (isResizable : boolean)
	        Sets whether the GUI can be resized vertically, after initialization.
	      setHorizontallyResizable (isResizable : boolean)
	        Sets whether the GUI can be resized horizontally, after initialization.
		  setAxes (canResizeHorizontally : boolean, canResizeVertically : boolean)
		    Sets whether the GUI can be resized in each direction (horizontally & vertically).
	
	Events:
		Updated ()
			Fired when the GUI size has changed.
	
	Demo:
	  local replStorage = game:GetService("ReplicatedStorage");
	  local Resizable = require (replStorage:WaitForChild ("Resizable"));
	
	  local player = game.Players.LocalPlayer
	  local gui    = player:WaitForChild("PlayerGui"):WaitForChild("DemoGui");
	  local frame  = gui:WaitForChild("MainFrame");
	
	  local resizing = Resizable.new (frame, {minimumSize = UDim2.new (0, 200, 0, 200)});
	
	  -- At this point, the DemoGui's MainFrame will be resizable.
--]]

local Resizable = { };
local R         = { };

local Handles     = require (script.Handles);
local Mouse       = require (script.Mouse);
local UserInput   = require (script.UserInput);
local Resizing    = require (script.Resizing);
local Persistance = require (script.Persistance);

local player = game.Players.LocalPlayer;

-- Constructor
function R.new (frame, options)
	if (not options) then options = { }; end
	
	local resizable = setmetatable({
		_frame   = frame,
		
		_mouse   = Mouse.new (player),
		_ui      = UserInput.new(),
		_persist = Persistance.new (player, frame, options),
		
		_options = options,
		
		_isUpdating = false,
		
		Updated = Instance.new ("BindableEvent")
	}, Resizable);
	
	-- initialize
	resizable:_init ();
	return resizable;
end

-- Public Methods
function Resizable:remove ()
	self._handles:remove ();
	self._ui:remove ();
end
function Resizable:hide ()
	self._handles:hide ();
end
function Resizable:show ()
	self._handles:show ();
end

function Resizable:save ()
	self._persist:save();
end

function Resizable:setAxes (canResizeHorizontal, canResizeVertical)
	self._handles:setHorizontalVisible (canResizeHorizontal);
	self._handles:setVerticalVisible (canResizeVertical);
end
function Resizable:setVerticallyResizable (isResizable)
	self._handles:setVerticalVisible (isResizable);
end
function Resizable:setHorizontallyResizable (isResizable)
	self._handles:setHorizontallyVisbile (isResizable);
end

-- Initialize
function Resizable:_init ()
	self._persist:load ();
	self:_initializeModules ();
	self:_listenForEvents ();
end

-- Initialize Modules
function Resizable:_initializeModules ()
	self._handles = Handles.new (self._frame, self._options);
	self._resize  = Resizing.new (self._frame, self._options);
end

-- Connect events
function Resizable:_listenForEvents ()
	self:_connectHandlesEvents ();
	self:_connectInputEvents ();
end
function Resizable:_connectHandlesEvents ()
	local handles = self._handles;
	handles.UpdateMouseIcon.Event:connect (function (icon)
		self:_setMouseIcon (icon);
	end)
end
function Resizable:_connectInputEvents ()
	local input = self._ui;
	
	input.Dragged.Event:connect (function (position)
		self:_updateFrameSize (position);
	end)
	input.ButtonUp.Event:connect (function ()
		self:_onButtonUp ();
	end)
	input.MouseMoved.Event:connect (function (position)
		self:_onMouseMoved (position);
	end)
end

-- Mouse Methods
function Resizable:_setMouseIcon (icon)
	self._mouse:setIcon (icon);
end

function Resizable:_onButtonUp ()
	self._handles:setActive (nil);
	
	if (self._isUpdating) then
		self._persist:update ();
		self.Updated:Fire ();
	end
end

function Resizable:_onMouseMoved (position)
	if (not self._handles:isWithinHandle (position)) then
		self:_setMouseIcon (nil);
	end
end

-- Resizing
function Resizable:_updateFrameSize (position)
	self._resize:update (position, self._handles:getActive ());
	self._isUpdating = true;
end

Resizable.__index = Resizable;
return R;