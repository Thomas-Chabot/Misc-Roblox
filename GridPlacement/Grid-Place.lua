--[[
	Provides a system to move a model around inside of a grid
	  with snapping to a specified amount.

	-- MUST BE USED LOCALLY --

	DEPENDENCIES:
    	Objectify.lua
		Recurse.lua

		Both must be placed within ReplicatedStorage.


	DOCUMENTATION:
		:new (args : Dictionary)
			Description: Creates a new Grid object which can be used to initialize the grid.
			Arguments:
				args: Dictionary. Should provide the following:
					grid: Dictionary specificing min & max coordinates of the grid. Should look like:
						grid = {
							min = {
								X = MIN_X_GRID_VALUE,
								Y = MIN_Y_GRID_VALUE
							},
							max = {
								X = MAX_X_GRID_VALUE,
								Y = MAX_Y_GRID_VALUE
							}
						}
						Note that Y here actually maps to a Z coordinate.
							So the Z axis of Vector3 would be between MIN_Y_GRID_VALUE
							  and MAX_Y_GRID_VALUE.
					snap: X,Y coordinates to snap grid to. Should be set up as:
						{
							X = X_SNAP,
							Y = Y_SNAP
						}
					transparency: [OPTIONAL] Number, [0, 1].
						Transparency to be given to any models/parts placed.
						Defaults to 0.5.
			Returns: A new Grid object.
		:place (obj : PVInstance, autoplace: boolean, callback : function)
			Description: Begins placement of a given object onto the grid.
			Arguments:
				obj: Any BasePart or Model to be placed within the grid.
				autoplace: If true, will place the model into the grid on click -
				            if false, will instead leave this to the callback.
				callback: A function to run. Function should take a single parameter,
			 	            being the final position for the object.
			Returns: Nothing. Will return through callback function.
		:cancel ()
			Description: Cancels the current placement.
			Arguments: None.
			Returns: Nothing.
--]]

local Grid    = { };

local repl    = game:GetService("ReplicatedStorage");
local Object  = require(repl.Objectify);
local recurse = require(repl.Recurse);

local DEFAULT_TRANSPARENCY = 0.5;

-- **** CONSTRUCTOR **** --
function Grid.construct (options)
	if (not options) then options = { }; end

	local grid = options.grid;
	local snap = options.snap;
	local trans = options.transparency or DEFAULT_TRANSPARENCY;

	if (not grid) then Grid._throw("Unspecified Argument: grid"); end
	if (not snap) then Grid._throw ("Unspecified Argument: snap"); end

	return {
		grid    = grid,
		snap    = snap,
		running = false,

		transparency = trans
	};
end

-- **** PUBLIC METHODS **** --
-- Start a placement
function Grid:place (obj, auto, callback)
	if (self.running) then
		self._throw("Grid placement system already running");
	end

	if (not obj) then self._throw("Unspecified Argument: obj"); end
	if (not callback) then self._throw("Unspecified Argument: Callback"); end

	self.running     = true;
	self.model       = obj;
	self.callback    = callback;
	self.auto        = auto;
	self:_rebuild ();

	-- start running ...
	self:_start ();
end

-- Cancel a placement
function Grid:cancel ()
	if (self.placeholder) then
		self.placeholder:Destroy ();
	end

	self.placeholder = nil;
	self.model       = nil;
	self.running     = false;

	self:_disconnect ();
end

-- **** PRIVATE METHODS **** --
-- Build the placeholder model
function Grid:_build (model)
	if (not model) then self._throw("Unspecified Argument: Model"); end

	local p  = model:Clone ();
	p.Parent = workspace;

	self:_placeholderify (p);
	self:_filter (p);


	return p;
end

-- Rebuild ..
function Grid:_rebuild ()
	self.placeholder = self:_build (self.model);
end
-- Apply the class magic
function Grid:_placeholderify (m)
	local _applyTo = function (part)
		part.Transparency = self.transparency;
		part.Anchored     = true;
	end

	local _check = function(p) return p:IsA("BasePart"); end

	recurse (m, _applyTo, _check);
end

-- Snap to grid
function Grid:_snap (position)
	local __snap = function(x, to)
		return math.floor (x / to) * to;
	end

	return Vector3.new (
		__snap (position.X, self.snap.X),
		position.Y,
		__snap (position.Z, self.snap.Y)
	);
end

function Grid:_positionTo (newPosition, model)
	if (not model and not self.placeholder) then
		self._throw("No placeholder model!");
	end
	local m = model or self.placeholder;

	if (m:IsA("BasePart")) then
		m.Position = newPosition; -- benefit of moving on top
	elseif (m:IsA("Model")) then
		m:MoveTo (newPosition);
	else
		self._throw ("UNKNOWN PLACEMENT TYPE");
	end
end

-- Run callback ...
function Grid:_place (model, position)
	model.Parent = workspace;
	self:_positionTo (position, model);
end

function Grid:_stop (pos)
	local cb = self.callback;
	local m  = self.model;

	self:cancel ();

	if (self.auto) then
		self:_place (m, pos);
	end

	cb (pos);
end

-- Disconnect events
function Grid:_disconnect ()
	local events = self._events;
	for _,evt in pairs (events) do
		evt:Disconnect ();
	end
end


-- React to mouse movements
function Grid:_move (mouse)
	local calc = self:_snap (mouse.Hit.p);
	if (not self:_valid (calc)) then return false end
	if (not self.placeholder) then
		self:_rebuild();
	end

	self:_positionTo (calc);
end

-- React to mouse clicks
function Grid:_click (mouse)
	local pos = self:_snap (mouse.Hit.p);
	if (not self:_valid (pos)) then return false end

	-- we can end at this point
	self:_stop (pos);
end

-- Control TargetFilter
function Grid:_filter (target)
	if (not self._mouse) then return false end;
	self._mouse.TargetFilter = target;
end

-- Main function
function Grid:_start ()
	local player  = game.Players.LocalPlayer;
	local mouse   = player and player:GetMouse ();
	if (not mouse) then
		self._throw ("Could not find mouse");
	end

	local moveEvt = mouse.Move:connect (function()
		self:_move (mouse);
	end);
	local clickEvt = mouse.Button1Down:connect (function ()
		self:_click (mouse);
	end)

	self._mouse        = mouse;
	self:_filter (self.placeholder);

	self._events = {
		click = clickEvt,
		move  = moveEvt
	};
end

-- *** ERROR CHECKING *** --
-- throw an error
function Grid._throw (message)
	return error (message);
end

-- check if position is valid
function Grid:_valid (position)
	local min = self.grid.min;
	local max = self.grid.max;

	local _valid = function (x, min, max)
		return (x >= min and x <= max);
	end

	return _valid (position.X, min.X, max.X) and
	       _valid (position.Z, min.Y, max.Y);
end

return Object.new (Grid);
