-- OSHIT WADDUP
function extend (de, ba)
	return setmetatable (de, {
		__index = function (table, key)
			if (not ba [key]) then return nil; end
			return ba [key];
		end
	});
end

