local RecentSaves = { };
local RS          = { };

function RS.new ()
	return setmetatable({
		_saves = { }
	}, RecentSaves);
end

function RecentSaves:reset ()
	for _,player in pairs(game.Players:GetPlayers()) do
		self._saves [player] = false;
	end
end

function RecentSaves:saved (player)
	self._saves [player] = true;
end

function RecentSaves:done ()
	for player,saved in pairs (self._saves) do
		if (not saved) then
			return false;
		end
	end
	return true;
end

RecentSaves.__index = RecentSaves;
return RS;