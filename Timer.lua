--[[
	Handles a timer. Contains an event, start, and stop.
  
  Gotta add some documentation here
--]]


local T     = { };
local Timer = { };

function T.new()
	return setmetatable({
		Elapsed = Instance.new("BindableEvent"),
		_thread = nil
	}, Timer);
end

function Timer:start (tm)
	if (self._thread) then return false end;
	
	-- start the timer
	self:_start(tm);
end

function Timer:stop (fireEvents)
	if (not self._thread) then return false end;
	
	-- stop the timer
	self:_stop()
	
	-- if firing events, fire the event
	if (fireEvents) then
		self:_fire()
	end
end

-- *** PRIVATE METHODS *** --
function Timer:_start (tm)
	self._thread = coroutine.create(function()
		wait (tm)
		self:_fire();
	end)
	
	coroutine.resume (self._thread);
end
function Timer:_stop ()
	coroutine.yield(self._thread);
	self._thread = nil;
end

function Timer:_fire ()
	self.Elapsed:Fire()
end

Timer.__index = Timer;
return T;
