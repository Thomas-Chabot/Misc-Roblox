--[[
	A FadeIn animation to be called on a GUI element (Frame, Label, Box, Button).

	Supports the following options:
		runTime:	Time of animation effect to last (between fading in and fading out)
		duration:	How long the animation should take (fading in or fading out)
		textTrans:	Starting text transparency		                  [ OPTIONAL ]
		txt:		Text element to fade in/out with initial element  [ OPTIONAL ]
		startTrans:	Transparency to start fading in from
		endTrans:	Transparency to stop fading in at
		callback:	Callback function to call at the end of the animation

	Will automatically reverse self after $(runTime) seconds.
--]]
local FadeIn = { };

local repl         = game:GetService("ReplicatedStorage");
local Object       = require (repl.Objectify); -- Helper code.

local TweenService = game:GetService("TweenService");

function FadeIn.run (element, options)
	if (not element) then return false end;

	-- Run the animation ...
	local tweenInfo = FadeIn.createTweenInfo (options);
	FadeIn.animate (element, tweenInfo, options, function()
		wait (options.runTime);
		FadeIn.reverse (element, tweenInfo, options, options.callback);
	end);
end

function FadeIn.createTweenInfo (options)
	return TweenInfo.new(
		options.duration,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	);
end

function FadeIn.text (options, tweenInfo, callback)
	local propertyGoals = {
		TextTransparency = options.textTrans or 0
	};
	local tween = TweenService:create (options.txt, tweenInfo, propertyGoals);

	options.txt.TextTransparency = options.startTrans or 1;
	tween.Completed:connect(callback);
	tween:Play();
end

function FadeIn.animate (element, tweenInfo, options, callback)
	if (options.txt) then
		FadeIn.text (options, tweenInfo, function() end);
	end

	local propertyGoals = {
		BackgroundTransparency = options.endTrans or 0
	};

	local tween = TweenService:create (element, tweenInfo, propertyGoals);

	-- Set starting transparency
	element.Visible = true;
	element.BackgroundTransparency = options.startTrans or 1;

	-- Add the event handler to run callback
	tween.Completed:connect (callback);

	-- Run it
	tween:Play ();
end

function FadeIn.reverse (element, tweenInfo, options, callback)
	FadeIn.animate (element, tweenInfo, {
		endTrans   = options.startTrans or 1,
		startTrans = options.endTrans or 0,
		textTrans  = options.startTrans or 1,
		txt        = options.txt
	}, callback);
end

return Object.new (FadeIn);
