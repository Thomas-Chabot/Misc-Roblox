--[[
	A Text Animation for displaying a typing effect.

	Supports the following options:
		runTime:	Time of animation effect to last (between fading in and fading out)
		duration:	How long the animation should take (fading in or fading out)
		text:       The text to enter into the element
		callback:	Callback function to call at the end of the animation
--]]

local TextAnim = { };

local repl      = game:GetService("ReplicatedStorage");
local Object    = require (repl.Objectify); -- Helper code.

function TextAnim.run (element, options)
	local text = options.text;
	if (not text or not element) then return end;

	local animationLength = options.duration;
	local animationTime   = options.runTime;

	TextAnim.animate (element, "", text, animationLength);
	wait (animationTime);
	TextAnim.animate (element, text, "", animationLength);

	options.callback ();
end

function TextAnim.step (element, endText, i, length)
	element.Text = endText:sub (1, i);
	wait (length);
end

function TextAnim.animate (element, startText, endText, length)
	local lengthPer = length / (#endText - #startText);
	if (#startText > #endText) then
		return TextAnim.reverse (element, startText, endText, lengthPer);
	end

	for i = #startText, #endText do
		TextAnim.step (element, endText, i, lengthPer);
	end
end

function TextAnim.reverse (element, startText, endText, lengthPer)
	for i = #startText, #endText, -1 do
		TextAnim.step (element, startText, i, lengthPer);
	end
end

return Object.new (TextAnim);
