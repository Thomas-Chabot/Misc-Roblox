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
	
	local find = function (key)
		return derivedClass [key] or baseClass [key];
	end
	
	return setmetatable({
		object = {
			construct = derivedClass.construct,
			__index   = function(tab, key)
				return find (key)
			end
		}
	}, {
		__index = function (tab, key)
			return find (key);
		end
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
