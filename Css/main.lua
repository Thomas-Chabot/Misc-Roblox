--[[
	Calling this Css because I don't have a good name for it.

	Supports adding & removing classes, similarly to that of Jquery.

	DOCUMENTATION:
		:new (element : Instance, classes : PropertiesDictionary)
			Description: Constructs a new Css class.
			Arguments:
				element: The element to apply the classes to. Should be an instance.
				classes: Should be a dictionary mapping properties to values.
					Ex. Name = "George"
			Returns: New Css object.

		:addClass (class : string)
			Description: Adds the class specified by the given string.
			Arguments:
				class: The class to add.
			Returns: Self (for cascading)

		:removeClass (class : string)
			Description: Removes the class specified by the given string.
			Arguments:
				class: The class to remove.
			Returns: Self (for cascading)

	Properties can be any list of properties that are available for the given
	  element. For example, BrickColor can be used if the element is a BasePart
	  but not if the element is a Gui.

	When a class is added, the properties specified by the class will be added.
	When a class is removed, the properties specified by the class will be removed.
	  This will revert back to whatever was there when the object is created.

	Note that if several classes are applied that each affect the same thing, these
	  will not be applied in any specific order - and as such either may occur. This
	  is an edge case that will be fixed in the future with a future version.

  INSTALLATION:
      Insert the Classes.lua script into this script;
      Add Objectify.lua to ReplicatedStorage;
      Add Animation.lua to ReplicatedStorage
--]]

local Css = { };

local repl    = game:GetService("ReplicatedStorage");
local Object  = require(repl.Objectify);
local Classes = require(script.Classes);
local Animate = require(repl.Animation);

-- *** CONSTRUCTOR *** --
function Css.construct (element, classes)
	for i,v in pairs(classes) do print(i,v) end
	return {
		element  = element,
		_classes = classes
	};
end

function Css:load ()
	-- load the defaults
	local defaults = self:_loadDefaults (self._classes);
	self._classes.default = defaults;

	-- create the classes
	self.classes = Classes:new (self._classes);
end

-- *** PUBLIC METHODS *** --
function Css:addClass (class, animate)
	local properties = self.classes:add (class);
	return self:_update (properties, animate);
end

function Css:removeClass (class, animate)
	local properties = self.classes:remove (class);
	return self:_update (properties, animate);
end

-- *** PRIVATE METHODS *** --
function Css:_update (properties, animate)
	if (animate) then
		Animate.run ("tween", self.element, {properties = properties})
	else
		for prop,value in pairs (properties) do
			self.element[prop] = value;
		end
	end

	return self;
end

-- Load helpers
function Css:_grabValues (defaults, map)
	for prop,_ in pairs(map) do
		defaults [prop] = self.element [prop];
	end
end
function Css:_loadDefaults (classes)
	local defaults = { };

	for _,props in pairs(classes) do
		self:_grabValues (defaults, props);
	end

	return defaults;
end

return Object.new (Css);
