local t = {
	name = "George",
	lastName = "Bambino"
};

local r = {
	toString = function(self) return self.name; end,
	myName = function(self) return self.name; end
}
r.__index = r;

local p = {
	toString = function(self) return self.name .. " " .. self.lastName; end,
	myLastName = function (self) return self.lastName; end
}
p.__index = p;

local b = {
	toString = function (self) return self.name .. " " .. self.lastName .. " ! "; end
}

local R = setmetatable(t, r);

function extend (de, ba)
	return setmetatable (de, {
		__index = function (table, key)
			if (not ba [key]) then return nil; end
			return ba [key];
		end
	});
end

local C = extend (p, R);
local D = extend (b, C);


print (D, D.toString);
print (D:toString ())
print (D:myName ());
print (D:myLastName ());
