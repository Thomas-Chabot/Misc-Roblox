--[[
	Allows a button to easily swap image based on Mouse Hover & Mouse Down
	By supplying a button and the various images to use.
	
	To apply these effects, simply create a new ButtonStyles object:
		Constructor  (button : ImageButton, options : Table) : ButtonStyles
			Purpose: Creates & adds effects for the given button based on given options.
			Arguments:
				button  : ImageButton : The button to apply the effects to
				options : Table       : Table of settings to apply. See OPTIONS below
			Returns:
				A ButtonStyles object. Currently, the object will have no further
				  purpose.
		
		OPTIONS:
			Options can take on three properties:
				mouseHover  String  Image to be applied for hovering
				mouseDown   String  Image to be applied when mouse is pressed
				default     String  Image to be applied as default (i.e., not hovered, not pressed)
			Note that each option is optional; if not provided, will not apply that effect
--]]

local BS           = { };
local ButtonStyles = { };

local effects = {
	MouseDown = {
		priority = 2,
		image    = "downImg",
		id       = 1
	},
	MouseHover = {
		priority = 1,
		image    = "hoverImg",
		id       = 2
	},
	Default = {
		priority = 0,
		image    = "default",
		id       = 3
	}
};

-- constructor
function BS.new (button, options)
	assert(button, " button argument must be provided ");
	if (not options) then options = { }; end
	
	local t = setmetatable({
		button = button,
		hoverImg = options.mouseHover,		
		downImg  = options.mouseDown,
		default  = options.default or button.Image,
		
		applied  = { }
	}, ButtonStyles);
	
	t:init();
	return t;
end

-- initialization
function ButtonStyles:init ()
	local btn = self.button;
	if (not btn) then return end;
	
	btn.MouseButton1Down:connect(function()
		self:_applyMouseDown();
	end)
	btn.MouseButton1Up:connect(function()
		self:_removeMouseDown();
	end)
	
	btn.MouseEnter:connect(function()
		self:_applyHover();
	end)
	btn.MouseLeave:connect(function()
		self:_removeHover();
	end)
end

-- effects
-- [ should be protected methods ]
function ButtonStyles:_applyMouseDown ()
	self:_apply (effects.MouseDown);
end
function ButtonStyles:_removeMouseDown ()
	self:_unapply (effects.MouseDown);
end
function ButtonStyles:_applyHover ()
	self:_apply (effects.MouseHover);
end
function ButtonStyles:_removeHover ()
	self:_unapply (effects.MouseHover);
	
	-- note, error case: may not have unpressed mouse down, but should.
	-- worst case, will not do anything...
	self:_removeMouseDown();
end

-- applying & removing effect
-- this will follow a chain of importance ...
function ButtonStyles:_apply (effect)
	if (self:_hasApplied (effect)) then return false end
	self:_addApplied (effect);
	self:_update ();
end
function ButtonStyles:_unapply (effect)
	self:_removeApplied (effect);
	self:_update ();
end

-- storing applied features
function ButtonStyles:_indexOf (effect)
	for index,e in pairs(self.applied) do
		if (e.id == effect.id) then
			return index
		end
	end
	return -1	
end
function ButtonStyles:_hasApplied (effect)
	return self:_indexOf (effect) ~= -1;
end
function ButtonStyles:_addApplied (effect)
	table.insert (self.applied, effect);
end
function ButtonStyles:_removeApplied (effect)
	local index = self:_indexOf (effect);
	if (index ~= -1) then
		table.remove (self.applied, index);
	end
end

-- returns the image to apply based on effects,
--   which will be highest priority or default
function ButtonStyles:_getCurrentImage ()
	local effect = self:_getHighestPriority ()
	if (not effect) then effect = effects.Default end
	
	return effect.image
end

-- returns the effect to apply with highest priority
-- returns nil if no effects being applied
function ButtonStyles:_getHighestPriority ()
	local index = 1
	local applied = self.applied;
	
	if (#self.applied == 0) then return nil end
	
	local index = self:_getHighestPriorityIndex();
	
	return applied[index];
end
function ButtonStyles:_getHighestPriorityIndex ()
	local index = 1;
	local applied = self.applied;
	
	for i,e in pairs (applied) do
		if (e.priority > applied[index].priority) then
			index = i;
		end
	end
	
	return index;
end

-- apply effects
function ButtonStyles:_update ()
	local imageName = self:_getCurrentImage ();
	
	-- use default if no effect to apply ...
	if (not imageName) then
		imageName = "default";
	end
	
	local image = self[imageName];
	if (not image) then return end;
	
	self.button.Image = image;
end

ButtonStyles.__index = ButtonStyles;
return BS;
