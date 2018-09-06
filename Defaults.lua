--[[
	Simple module for applying default values to a table.
	
	Usage:
		The Defaults class should be constructed with all the default values.
		When options are provided, the apply method should be called on the table of options;
		  this will apply all default values to the options table.
	
	Documentation:
		Constructor (defaultValues : table)
			Purpose: Creates the Defaults object;
			Arguments:
				defaultValues  table  A table of default values to be applied when a value is not specified.
		
		apply (values : table) : table
			Purpose: Applies the default values, such that either the value is provided or the default is used.
			Arguments:
				values  table  The table of options already specified. Each provided value will be used in the final result.
			Returns: The final result table, combining specified values with defaults for unspecified values.
--]]

local Defaults = { };
local D        = { };

function D.new (defaultValues)
	return setmetatable ({
		_defaults = defaultValues
	});
end

function Defaults:apply (values)
	if (not values) then values = { }; end
	local result = { };
	
	for key,value in pairs (self._defaults) do
		result [key] = values [key] or value;
	end
	
	return result;
end

Defaults.__index = Defaults;
return D;
