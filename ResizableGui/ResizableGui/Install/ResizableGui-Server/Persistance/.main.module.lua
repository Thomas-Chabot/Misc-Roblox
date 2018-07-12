local Persistance = { };

local DataStoreService = game:GetService("DataStoreService");
local sizeDataStore;
pcall (function ()
	sizeDataStore = DataStoreService:GetDataStore("GuiSizes");
end)

function getKey (player, key)
	return player.userId .. " - " .. key;
end

function try (f, errorMsg)
	local valid = pcall (f);
	if (not valid) then
		print (errorMsg);
	end
end

function Persistance.save (player, key, value)
	key = getKey (player, key);
	try (function() sizeDataStore:SetAsync (key, value) end, "could not save");
end

function Persistance.load (player, key)
	key = getKey (player, key);
	
	local data;
	try(function() data = sizeDataStore:GetAsync (key); end, " could not get")
	return data;
end

return Persistance;