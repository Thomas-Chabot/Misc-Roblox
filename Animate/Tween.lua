--[[
	Default animation for Tweening based on TweenService.

	Supports the following options:
		EITHER
			tweenInfo		An already created TweenInfo object
		OR
			duration		Length for each interpolation
			easingStyle		Easing style for interpolation
			easingDirection	Easing ... direction
			repeats			Number of times to repeat while played back to back
			reverse			Indicates if will play back after reaching goal
			delayTime		Delay between each sequence if repeated or reversed
			[ NOTE : All of these are for TweenInfo constructor ]

		properties : dictionary < Variant >    [ REQUIRED ]
	Does not by default reverse.
--]]

local Tween = { };

local repl      = game:GetService("ReplicatedStorage");
local Object    = require (repl.Objectify); -- Helper code.

local TweenService = game:GetService("TweenService");

function Tween.run (element, options)
	if (not element) then return false end;

	local tweenInfo = options.tweenInfo;
	if (not tweenInfo) then
		tweenInfo = Tween.createInfo (options);
	end

	Tween.animate (element, tweenInfo, options);
end

function Tween.createInfo (options)
	return TweenInfo.new(
		options.duration,
		options.easingStyle,
		options.easingDirection,
		options.numRepeats,
		options.reverse,
		options.delayTime
	);
end

function Tween.animate (element, tweenInfo, options)
	local tween = TweenService:Create (element, tweenInfo, options.properties);
	tween.Completed:connect (options.callback);
	tween:Play()
end

return Object.new (Tween);
