-- The server code for Resizable GUIs.
local Persistance = require (script.Persistance);
local Frames      = require (script.Frames);

-- Server connections
local replStorage      = game:GetService("ReplicatedStorage");
local resizable        = replStorage:WaitForChild ("ResizableGui");
local remoteFuncs      = resizable:WaitForChild ("RemoteFunctions");
local remoteEvents     = resizable:WaitForChild ("RemoteEvents");
local getData          = remoteFuncs:WaitForChild ("GetData");
local setData          = remoteEvents:WaitForChild ("SetData");
local update           = remoteEvents:WaitForChild ("Update");

local playerFrames     = { };

local _debug = false;

function log (...)
	if (_debug) then
		print (...);
	end
end

function saveData (player, key, value)
	log ("Saving ", key, " as ", value, " for player ", player);
	Persistance.save (player, key, value);
	log ("Saved.");
end

function updateData (player, key, value)
	log ("Updating data for ", player, " : key ", key, " & value ", value);
	if (not playerFrames [player]) then
		playerFrames [player] = Frames.new ();
	end
	
	playerFrames [player]:get (key):set (value);
end

function loadData (player, key)
	local value = Persistance.load (player, key);
	log ("Loaded ", key, " : value is ", value);
	return value;
end

function savePlayerData (player)
	if (not playerFrames [player]) then return end

	local pFrames = playerFrames [player];
	playerFrames [player] = nil;
	
	pFrames:each (function (frame)
		saveData (player, frame.key, frame.value)
	end)
end

function saveAllData ()
	for player in pairs (playerFrames) do
		savePlayerData (player);
	end
end

setData.OnServerEvent:connect (saveData);

update.onServerEvent:connect (updateData);

function getData.OnServerInvoke (player, key)
	return loadData (player, key);
end

game.Players.PlayerRemoving:connect (function (player)
	-- Special case: If the server will shutdown, leave it to the server to save
	if (#game.Players:GetPlayers() <= 1) then return end

	savePlayerData (player);
end)

game:BindToClose (function ()
	-- Save all data before the game closes ...
	saveAllData();
end)