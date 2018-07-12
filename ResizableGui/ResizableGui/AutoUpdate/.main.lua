local insertService = game:GetService ("InsertService");
local modelId = 1283728854;
local this    = script.Parent;

function getVersion (model)
	return model.Control.Version.Value;
end

function insert (id)
	local result = nil;
	pcall (function ()
		local model = insertService:LoadAsset (id);
		result = model and model:GetChildren()[1];
	end);
	
	return result;
end

function getLatest ()
	local latest = insert (modelId);
	if (not latest) then
		print ("Could not insert latest version of model.");
		print ("Will need to be manually updated.");
		return this;
	end
	
	if (getVersion (latest) > getVersion (this)) then
		print ("Newer model of ResizableGui found");
		return latest;
	end
	return this;
end

local model = getLatest();
require (model.Control.Installer) ();