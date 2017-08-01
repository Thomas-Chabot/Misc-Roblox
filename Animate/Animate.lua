--[[
	Applies default values, if not already specified, to run animations.
	Works as a handler so that animations will be very closely related,
	  looking better. Any option can be overridden.

	Default options, supported for all animations, are:
		Duration : number		Duration for a single animation
		runTime  : number		How long between animation start, reversed [ IF REVERSES ]
		callback : function		Function to call after animation complete

	Further options are explained within each inner module.

	Simple syntax to run animations:
		Animate.run (type : string, element : Object, options : Dictionary)

	Supported types are:
		FadeIn
		TextType
		Tween

	INSTALLATION:
		Create a new ModuleScript and insert this code into it.
		Insert FadeIn, TextDisplay, and Tween as ModuleScripts into this ModuleScript.
		Add Objectify (from this repo) into ReplicatedService as a ModuleScript.

		Require this module to start running animations!
--]]

local Animation = { };

local repl      = game:GetService("ReplicatedStorage");
local Object    = require (repl.Objectify); -- Helper code.

-- Animations
local TextAnim  = require (script.TextDisplay);
local FadeIn    = require (script.FadeIn);
local Tween     = require (script.Tween);

local animations = {
	textdisplay = TextAnim,
	fadein      = FadeIn,
	tween       = Tween
};

local animationDefaults = {
	duration = 1, -- duration for an animation
	runTime  = 3,  -- length of time before animation reverses
	callback = function() end
};

function Animation.run (class, element, opts, ...)
	local animation = Animation._find (class);
	if (not animation) then return false end;

	opts = Animation._applyDefs (opts);

	local args = {...}
	spawn (function ()
		animation.run (element, opts, unpack (args));
	end)
end

function Animation._find (name)
	name = name:lower ();
	return animations [name];
end

function Animation._applyDefs (options)
	if (not options) then options = { }; end
	for key,value in pairs (animationDefaults) do
		if (options [key] == nil) then -- note, false here would stay as false ..
			options[key] = value;
		end
	end
	return options;
end

return Object.new (Animation);
