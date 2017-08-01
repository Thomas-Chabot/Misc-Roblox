--[[
  An object to control classes and a class's properties.
  Returns all properties for all classes currently in use
    for a given element, as well as the defaults for any
    class that was removed.

  Documentation:
    :new (classes)
      Description: Constructs a new Classes handler.
      Arguments:
        classes: A dictionary relating class names to properties.
          Ex.
            active = {
              Name = "Active"
            }
      Returns: A new Classes object.
    :has (class)
      Description: Checks if the given class is active.
      Arguments:
        class: Some class name.
      Returns: Boolean. True if the class is currently active.
    :add (class)
      Description: Sets a class to active, adding its properties.
      Arguments:
        class: The class name identifier.
      Returns: The list of properties which should currently be active.
    :remove (class)
      Description: Sets a class as inactive, removing its properties.
      Arguments:
        class: The class name identifier.
      Returns: The list of properties which should currently be active.

  Installation:
    Insert this script into main.lua
    Follow the instructions within main.lua
]]

local Classes = { };

local repl    = game:GetService("ReplicatedStorage");
local Object  = require(repl.Objectify);

-- *** CONSTRUCTOR *** --
function Classes.construct (classes)
	local t = {
		classes = { }
	};

	-- construct the dictionary of class : properties
	for class,props in pairs (classes) do
		t[class] = props;
	end

	return t;
end

-- *** PUBLIC METHODS *** --
-- check if element has a class
function Classes:has (class)
	return self.classes [class] ~= nil;
end

-- add a class
function Classes:add (class)
	self.classes [class] = true;
	return self:_update ();
end

-- remove a class
function Classes:remove (class)
	self.classes [class] = nil;
	return self:_update (self[class]);
end

-- *** PRIVATE HELPER METHODS *** --
-- Update active properties
function Classes:_update (removedClass)
	local props = { };

	if (removedClass) then
		self:_addDefaultProps (props, removedClass);
	end

	for class,_ in pairs (self.classes) do
		self:_addProps (props, self[class]);
	end

	return props;
end

-- add properties of a class that the element has
function Classes:_addProps (res, class)
	if (not class) then return end;
	for prop,value in pairs (class) do
		res [prop] = value;
	end
end

-- add default properties for a class that the element is removing
function Classes:_addDefaultProps (res, removed)
	if (not self.default) then return end;

	for prop,_ in pairs (removed) do
		res[prop] = self.default[prop];
	end
end

return Object.new (Classes);
