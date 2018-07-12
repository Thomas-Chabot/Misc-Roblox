--[[
	Allows a single Handle to be created.
	
	Takes the following options to the constructor:
		id    :  string  [optional] Id to use for the Handle. Passed into events.
		img   :  string  [optional] Image to be passed back through Hovered event.
		postition :  UDim2   [required] Position to place the Handle
		size  :  UDim2   [required] Size to use for the Handle
		parent : Frame   [required] Parent Frame to place the Handle into
		bgColor: Color3  [optional] Color3 to use for the BackgroundColor of the Handle
		                              Defaults to {255, 192, 103}
		bgTrans: Number  [optional] Transparency to use for the background of the Handle
		                              Defaults to 0.2.
	
	Has the following events:
		Activated (id : string)   Called when the Handle is activated.
		Deactivated (id : string) Called when the Handle is deactivated.
		Entered (image : string,
		         id    : string)  Called when the mouse hovers over the handle.
		Left (id : string)        Called when the mouse leaves the Handle.
	
--]]

local Handle = { };
local H      = { };

-- Static Functions
local id = 0;
function nextId()
	id = id + 1;
	return id;
end

function isClick (input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
	  or input.UserInputType == Enum.UserInputType.Touch;
end

function isWithin (button, position)
	local absPos = button.AbsolutePosition;
	local absSize = button.AbsoluteSize;
	
	return position.X >= absPos.X and position.Y >= absPos.Y
	   and position.X <= absPos.X + absSize.X and position.Y <= absPos.Y + absSize.Y;
end

function retTrue() return true; end

-- Constructor
function H.new (details)
	local handle = setmetatable({
		_hoverImage = details.img,
		_position   = details.position,
		_size       = details.size,
		
		_parent     = details.parent,
		
		_bgColor    = details.bgColor or Color3.fromRGB(255, 192, 103),
		_bgTrans    = details.bgTrans or 0.2,
		
		_id         = details.id or nextId(),
		
		_button     = nil,
		
		Activated   = Instance.new("BindableEvent"),
		Deactivated = Instance.new("BindableEvent"),
		Entered     = Instance.new("BindableEvent"),
		Left        = Instance.new("BindableEvent")
	}, Handle);
	handle:_init ();
	return handle;
end

-- Public Methods
function Handle:contains (position)
	return isWithin (self._button, position);
end

function Handle:hide ()
	self:setVisible (false);
end
function Handle:show ()
	self:setVisible (true);
end
function Handle:setVisible (isVis)
	if (not self._button) then return end
	self._button.Visible = isVis;
end
-- Initialization
function Handle:_init ()
	local button = self:_createButton ();
	
	button.MouseLeave:connect (function ()
		self.Left:Fire (self._id);
	end)
	button.MouseEnter:connect (function ()
		self.Entered:Fire (self._hoverImage, self._id);
	end)
	
	button.InputBegan:connect (function (input, gameProcessed)
		if (isClick (input) and not gameProcessed) then
			self.Activated:Fire (self._id);
		end
	end)
	--[[button.InputEnded:connect (function (input, gameProcessed)
		if (isClick (input) and not gameProcessed) then
			self.Deactivated:Fire (self._id);
		end
	end)]]
	
	self._button = button;
end

function Handle:_createButton ()
	local button = Instance.new("ImageLabel");
	button.Name = "Handle" .. self._id;
	button.Position = self._position;
	button.Size     = self._size;
	button.BorderSizePixel = 0;
	button.BackgroundColor3 = self._bgColor;
	button.BackgroundTransparency = self._bgTrans;
	
	button.Parent = self._parent;
	return button;
end

Handle.__index = Handle;
return H;