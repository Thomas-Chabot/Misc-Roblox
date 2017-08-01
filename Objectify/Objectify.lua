--[[
  Simplifies the process of creating objects from tables.

  Usage:
    Call Object.new(OBJECT) to create a new Object wrapper.
    Call :new() on the wrapper to create a new object
      with optional arguments passed into its constructor.
  
  Method List:
    .new (object)
        Description: Creates a new Object
        Arguments:
          object: A list of methods and data to turn into an object
        Returns: The new Object
    .extend (derivedClass : table, baseClass : Object)
      Description: Extends the base class to create the derived class.
      Arguments:
        derivedClass: A table to use for the object (containing methods and data)
        baseClass: An Object to extend (created with Object.new or Object.extend)
      Returns: The new derivedClass Object
]]

local SetupMain = { };
local Setup     = { };

-- Main objectify function
function SetupMain.new (object)
	object.__index = object;
	return setmetatable({
		object = object
	}, {
		__index = function (tab, key)
			return Setup [key] or object [key];
		end
	});
end

-- Extend
function SetupMain.extend (derivedClass, baseClass)
	derivedClass = SetupMain.new (derivedClass);

	local find = function (tab, key)
		-- 'super' keyword
		if (key == "super") then
			return baseClass;
		end

		return derivedClass [key] or baseClass [key];
	end

	return setmetatable({
		object = {
			construct = derivedClass.construct,
			__index   = find
		}
	}, {
		__index = find
	});
end

-- Setup - Does the stuff for creating new objects
function Setup:new (...)
	local obj = setmetatable(self.object.construct (...), self.object);

	-- load it, if there's a method for it ...
	if (obj.load) then
		obj:load ();
	end

	-- return it
	return obj;
end

Setup.__index = Setup;
return SetupMain;
