--[[
	This is the Grid Placement Module redeisgned to be easier to read & edit.
	  Everything is constrained into its own objects & there are no outside dependencies.
	
	The constructor for this module works as follows:
		Module.new (grid : Table, snap : Table, transparency : float)
		Arguments:
			grid : Table : Should define min & max positions for the grid, in the following format:
				min = {
					X = MIN_X_GRID_VALUE,
					Y = MIN_Y_GRID_VALUE
				},
				max = {
					X = MAX_X_GRID_VALUE,
					Y = MAX_Y_GRID_VALUE
				}
			snap: Table : The amount to snap the grid to. Should be set as the following:
				{
					X = X_SNAP,
					Y = Y_SNAP
				}	
			transparency: float : Some number of transparency to provide. Should be between
			                        0 and 1; deafults to 0.5.
	
	The object then has two available methods:
		place (object : PVInstance, doAutoPlace : boolean)
			Performs a grid placement, allowing the player to select a position for the object.
			Arguments:
				object  PVInstance  The object for the player to place. This will be copied to use
				                      as a placeholder, so archivable must be true.
				doAutoPlace  boolean  If true, the object will be automatically placed when the user
				                        has selected a position.
			Note: This may only be called once until the user has selected a placement for the object.
			        Otherwise, an error will be thrown.
		
		cancel ()
			Cancels the placement of the object. This will remove any placeholder objects that have
			  been created and stops the module from responding to user input.
	
	The object also has a single event:
		Placed (position : Vector3)
			Fired when the player has selected a position at which to place the object.
			The provided position indicates the position that the user has selected.
			
	EXAMPLE USAGE
		local Grid = require (workspace.MainModule); -- The grid module
		
		-- Initial setup
		local grid = Grid.new ({
			min = {
				X = -256,
				Y = -256
			},
			max = {
				X = 256,
				Y = 256
			}
		}, {
			X = 5,
			Y = 5
		});
		
		-- Event connector - fires when the object has been placed
		grid.Placed.Event:connect (function (pos)
			print ("Placed at ", pos);
		end)
		
		-- Place the object, workspace.BlockODoom,
		-- With auto placement activated
		grid:place (workspace.BlockODoom, true)
--]]

local M    = { };

-- ** Dependencies ** --
local Input = require (script.Input);
local EventSystem = require (script.EventSystem);
local RayToPoint = require (script.RayToPoint);
local Placeholder = require (script.Placeholder);
local Grid = require (script.Grid);
local Object = require (script.Object);

-- ** Constants ** --
local DEF_TRANS = 0.5; -- Default transparency for the model being placed

-- ** Constructor ** --
local Main = EventSystem.new();
function M.new (grid, snap, transparency)
	assert (grid, "The grid is a required argument.");
	assert (snap, "The snap size is a required argument.");
	if (not transparency) then transparency = DEF_TRANS; end
	
	local grid = setmetatable ({
		-- constructor variables
		_grid = Grid.new (grid, snap),
		
		-- placement variables	
		_running = false,
		_object = nil,
		_doAutoPlace = false,
		
		_lastPoint = nil,
		
		-- objects
		_placeholder = Placeholder.new (transparency),
		_input = Input.new (),
		
		-- events
		Placed = Instance.new ("BindableEvent")
	}, Main);
	
	grid:_init ();
	return grid;
end

-- ** Public Methods ** --
function Main:place (object, doAutoPlace)
	assert (not self._running, "A previous object is currently being placed.");
	
	self._object = object;
	self._doAutoPlace = doAutoPlace;
	
	self._placeholder:create (object);
	
	self._running = true;
end
function Main:cancel ()
	self._placeholder:remove ();
	
	self._running = false;
end

-- ** Private Methods ** --
-- * Module Initialization * --
-- Main entry point for initialization
function Main:_init ()
	self:_addEvents ();
end

-- Adds the event handlers
function Main:_addEvents ()
	self:_connect (self._input.PositionChanged.Event, self._onPositionChanged);
	self:_connect (self._input.ButtonReleased.Event, self._onButtonRelease);
end

-- * Event Handling * --
-- Position change detection
function Main:_onPositionChanged (ray, isMouseDown)
	-- Only do anything when the mouse is down & we are placing something
	if (not self._running) then return end
	
	local position = RayToPoint.findPoint (ray, self._placeholder:get());
	self:_updateModelPosition (position);
end

-- Reacts to the button being released - should place the object
function Main:_onButtonRelease ()
	if (not self._running) then return end
	self:_placeObject ();
end

-- Move the placeholder model
function Main:_updateModelPosition (position)
	-- Convert it into a valid point in the grid
	local gridSnap = self._grid:getSnapped (position);
	if (not gridSnap) then return end
	
	-- Set the last point - in case the player ends here
	self._lastPoint = gridSnap;
	
	-- Move to that point
	self._placeholder:moveTo (gridSnap);
end

-- Placing the object
function Main:_placeObject ()
	local position = self._lastPoint;
	self._placeholder:remove ();
	
	-- Place the object
	self:_doMoveObject (position);
	
	-- Fire off the event
	self:_firePlacedEvent (position);

	self:cancel()
end

function Main:_doMoveObject (position)
	if (self._doAutoPlace) then
		Object:moveTo (self._object, position);
	end
end

-- The event trigger
function Main:_firePlacedEvent (...)
	self.Placed:Fire (...);
end

Main.__index = Main;
return M;