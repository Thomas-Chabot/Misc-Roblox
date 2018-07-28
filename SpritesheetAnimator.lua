--[[
	Module for running animations from a Sprite Sheet.
	 Has support for vertical & horizontal spreadsheets (must be specified).
	
	
	Constructor:
		Animator.new (mainImgLbl : ImageObject, numSprites : int, options : Dictionary)
			mainImgLbl : ImageObject : The image object used to display the sprites.
			numSprites : int         : The number of sprites to cycle through.
			options    : Dictionary  : Various options for the animator. See OPTIONS
		
	Methods:
		start ()
			Starts cycling through animations. This will continue until stop() is called.
		stop ()
			Stops running the animations.
	
	Options:
		These are the various options that may be provided into the constructor.
		  Note that some are required while others are optional; [R] indicates required.
		
		[R] Direction  The Direction in which sprites are animated. This currently
		                 has support for Vertical and Horizontal; can be selected by
		                  Animator.Directions.Horizontal or Animator.Directions.Vertical.
		
		[O] SpriteSize The Size of each individual sprite. This defaults to the ImageRectSize
		                 defined on the ImageObject. Should be a Vector2.
		
		[O] FrameDelay The delay for each frame. Should be a number.
		                 Defaults to 0.03.
		
		[O] Frames     The delay to provide on each frame individually. If not defined,
		                 will use the default delay (FrameDelay). Should be a table of
		                   {FrameIndex = Delay}, eg. {[2] = 0.05} for a 0.05 delay on Frame 2.
	
	Directions:
		The Animator has support for two directions, Vertical & Horizontal, which should be
		  passed in through the options to the constructor.
		These can be found as either:
			Animator.Directions.Horizontal
			Animator.Directions.Vertical
	
	Example:
		local SpriteAnimator = require (game.ServerScriptService.SpriteAnimator);
		local imgLabel = script.Parent.ImageLabel;
		
		local animator = SpriteAnimator.new (
			imgLabel, -- The image object
			17, -- Number of frames
			{
				Direction = SpriteAnimator.Directions.Vertical, -- Direction of sprite sheet
				FrameDelay = 0.03, -- Delay for each frame
				Frames = {
					[17] = 0.5 -- Extra delay for the last frame, 17
				}
			}
		);
		
		-- Run the animation
		animator:start ();
--]]

local SpriteAnimator = { };
local SA             = { };

SA.Directions = {
	Horizontal = Vector2.new (1, 0),
	Vertical = Vector2.new (0, 1)
}

-- ** Constants ** --
local DEF_FRAME_DELAY = 0.03;

-- ** Constructor ** --
function SA.new (mainImgLbl, numSprites, options)
	assert (mainImgLbl, "The Image Label/Button is a required argument.");
	assert (numSprites, "The number of sprites to animate through is required");
	
	if (not options) then options = { }; end
	local sprite = setmetatable ({
		-- Main sprite information
		_imgLbl = mainImgLbl,
		_numSprites = numSprites,
		_spriteSize = options.SpriteSize or mainImgLbl.ImageRectSize,
		
		-- Frame direction
		_spriteDirection = options.Direction,
		
		-- Delay speeds
		_frameDelay = options.FrameDelay or DEF_FRAME_DELAY, -- Delay for frame if not specified
		_frames = options.Frames or { }, -- Delay for each frame, individually
		
		-- Internals
		_isAnimating = false,
		_runIndex = 0, -- Used to make sure we don't have two+ running at once
		_frameIndex = 0
	}, SpriteAnimator);

	return sprite;
end

-- ** Public Methods ** --
function SpriteAnimator:start ()
	if (self._isAnimating) then return end
	
	print ("Starting");
	
	self._isAnimating = true;
	self._runIndex = self._runIndex + 1;
	self:_start ();
end
function SpriteAnimator:stop ()
	self._isAnimating = false;
end

-- ** Private Methods ** --
-- Main start method
function SpriteAnimator:_start ()
	spawn (function ()
		self:_run ();
	end)
end

-- Runs the animation
function SpriteAnimator:_run ()
	local imageLabel = self._imgLbl;
	local currentRunIndex = self._runIndex;
	while (self._isAnimating and self._runIndex == currentRunIndex) do
		local frameIndex = self:_updateFrameIndex ();
		local newOffset = self:_getOffset (frameIndex);
		local waitTime = self:_getWaitTime (frameIndex);
		
		imageLabel.ImageRectOffset = newOffset;
		
		wait (waitTime);		
	end
end

-- Helper methods
-- Determines the new frame index
function SpriteAnimator:_updateFrameIndex ()
	local newIndex = (self._frameIndex + 1) % self._numSprites;
	self._frameIndex = newIndex;
	
	return newIndex;
end

-- Determines the offset for a given frame
function SpriteAnimator:_getOffset (frameIndex)
	local spriteMultiplier = self._spriteDirection * frameIndex;
	return spriteMultiplier * self._spriteSize;
end

-- Determines the wait time for a given frame
function SpriteAnimator:_getWaitTime (frameIndex)
	if (self._frames [frameIndex + 1]) then
		return self._frames [frameIndex + 1];
	end
	
	return self._frameDelay;
end

SpriteAnimator.__index = SpriteAnimator;
return SA;