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
		
		[R] Direction  The Direction to follow with the grid. Can be either Horizontal or Vertical.
		                 If this is Horizontal, will load sprites in each row in order;
		                 If this is Vertical, will be loaded column by column.
		
		[R] Grid       The Dimensions of the grid - i.e. number of rows & number of columns.
		                 Should be a dictionary of two values:
		                   Rows = # of rows (should be int);
	                       Cols = # of columns (should be int)
	
		[O] SpriteSize The Size of each individual sprite. This defaults to the ImageRectSize
		                 defined on the ImageObject. Should be a Vector2.
		
		[O] FrameOffset The Offset to apply for each frame. Will be added to the frame's default
		                   offset; eg. If SpriteOffset is (0, 1), will turn 60 -> 61.
	   	                   Should be Vector2.
	
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
		local Animator = require (game.ServerScriptService.SpriteAnimator);
		local imgLabel = script.Parent.ImageLabel;
		local numFrames = 12;
		
		local anim = Animator.new (imgLabel, numFrames, {
			Direction = Animator.Directions.Horizontal,
			FrameDelay = 0.05, -- .05 seconds between each frame
			Frames = {
				[12] = 0.5 -- Wait half a second on the final frame
			},
			
			Grid = {
				Rows = 4,
				Cols = 3
			} -- 3 x 4 grid - 3 columns, 4 rows
		});
		
		-- Run the animation
		anim:start ();
--]]

local SpriteAnimator = { };
local SA             = { };

SA.Directions = {
	Horizontal = Vector2.new (1, 0),
	Vertical = Vector2.new (0, 1)
}

-- ** Constants ** --
local DEF_FRAME_OFFSET = Vector2.new (0, 0);
local DEF_FRAME_DELAY = 0.03;

-- ** Constructor ** --
function SA.new (mainImgLbl, numSprites, options)
	assert (mainImgLbl, "The Image Label/Button is a required argument.");
	assert (numSprites, "The number of sprites to animate through is required");
	
	if (not options) then options = { }; end
	if (not options.Grid) then options.Grid = { }; end
	
	local sprite = setmetatable ({
		-- Main sprite information
		_imgLbl = mainImgLbl,
		_numSprites = numSprites,
		_spriteSize = options.SpriteSize or mainImgLbl.ImageRectSize,
		_frameOffset = options.FrameOffset or DEF_FRAME_OFFSET,
		
		-- Frame direction
		_spriteDirection = options.Direction,
		
		-- Delay speeds
		_frameDelay = options.FrameDelay or DEF_FRAME_DELAY, -- Delay for frame if not specified
		_frames = options.Frames or { }, -- Delay for each frame, individually
		
		-- Grid
		_numRows = options.Grid.Rows,
		_numCols = options.Grid.Cols,
		
		_curRow = 0,
		_curCol = 0,
		
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
		self:_updateGrid ();
		
		wait (waitTime);		
	end
end

-- Helper methods
-- Update the current grid row & column
function SpriteAnimator:_updateGrid ()
	local row = self._curRow;
	local col = self._curCol;
	
	if (self._spriteDirection == SA.Directions.Vertical) then
		self._curRow, self._curCol = self:_updateGridValues (row, col, self._numRows, self._numCols);
	else
		self._curCol, self._curRow = self:_updateGridValues (col, row, self._numCols, self._numRows)
	end
end

-- Updates the grid from
function SpriteAnimator:_updateGridValues (row, column, maxRow, maxCol)
	row = row + 1;
	if (row >= maxRow) then
		row = 0;
		column = column + 1;
		
		if (column >= maxCol) then
			column = 0;
		end
	end
	
	return row, column;
end

-- Determines the new frame index
function SpriteAnimator:_updateFrameIndex ()
	local newIndex = (self._frameIndex + 1) % self._numSprites;
	self._frameIndex = newIndex;
	
	return newIndex;
end

-- Determines the offset for a given frame
function SpriteAnimator:_getOffset (frameIndex)
	local spriteMultiplier = Vector2.new (self._curCol, self._curRow);
	local framePosition = spriteMultiplier * self._spriteSize;
	
	return framePosition + self._frameOffset;
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