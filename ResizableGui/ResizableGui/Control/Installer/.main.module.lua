local installFiles = script.Parent.Parent.Install;
local localCode    = installFiles.ResizableGui;
local serverCode   = installFiles["ResizableGui-Server"];

local serverScriptService = game:GetService ("ServerScriptService");
local replStorage         = game:GetService ("ReplicatedStorage");

function install()
	localCode.Parent = replStorage;
	serverCode.Parent = serverScriptService;
	serverCode.Disabled = false;
	
	script.Parent:Destroy()
	print ("Resizable GUI installed.")
	print ("Create Resizable GUIs by requiring ", localCode.Resizable:GetFullName(), " ...");
end

return install;