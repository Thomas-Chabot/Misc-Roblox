--[[
  A helper for dealing with events on GUI Elements.
  Deals with turning hover & active on / off.

  Returns two static functions:
    Evt.hover (gui, callback)
      Description: Calls callback when gui is hovered on & off of.
      Arguments:
        gui:       Some GUI element to use for detecting hover events.
        callback:  A function to be called with the first argument being a boolean,
                     active, determining whether hover is currently active.
    Evt.active (gui, callback)
      Description: Calls callback when gui is activated & deactivated.
      Arguments:
        gui:       Some GUI element to use for detecting activation events.
        callback:  A function to be called with the first argument being a boolean,
                     active, determining whether element is currently active.


  Installation:
    Insert this module, as EventHelper, into parent Gui-Css module.
    Follow instructions from Gui-Css module.
--]]

local Evt = { };

local events = {
	hover = {
		on = {
			"MouseEnter",
			"SelectionGained"
		},
		off = {
			"MouseLeave",
			"SelectionLost"
		}
	},
	active = {
		on = {
			"InputBegan"
		},
		off = {
			"InputEnded"
		}
	}
};

function connectEvents (events, gui, active, callback)
	for _,evt in pairs (events) do
		pcall (function ()
			gui [evt]:connect (function (...)
				callback (active, ...);
			end)
		end)
	end
end

function applyConnections (events, gui, callback)
	for i,v in pairs (events.on) do print(i,v) end
	connectEvents (events.on, gui, true, callback);
	connectEvents (events.off, gui, false, callback);
end

function Evt.hover (gui, callback)
	applyConnections (events.hover, gui, callback);
end
function Evt.active (gui, callback)
	applyConnections (events.active, gui, callback);
end

return Evt;
