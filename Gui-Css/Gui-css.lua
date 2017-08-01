--[[
	Controls adding classes to a GUI to respond to hover & activation.

	Works with two class types:
		active
			Properties to add when button is active (mouseButton1 or Touch)
		hover
			Properties to add when being hovered over (mouseEnter)

	Can be called by:
		GuiClass:new (guiElement, classes)

  Installation:
    Add Css and Objectify from this repo, as ModuleScripts, into ReplicatedStorage
    Create a ModuleScript containing this code
    Add EventHelper into the new ModuleScript for this code as EventHelper
  
--]]

local GuiClass = { };

local repl    = game:GetService ("ReplicatedStorage");
local Object  = require (repl.Objectify);
local Css     = require (repl.Css);
local Events  = require (script.EventHelper);

-- *** CONSTRUCTOR *** --
function GuiClass.construct (gui, types, animate)
	for i,v in pairs(types) do print(i,v) end
	return {
		gui     = gui,
		css     = Css:new (gui, types),
		animate = animate
	};
end

function GuiClass:load ()
	Events.hover (self.gui, function(enabled)
		self:_activate ("hover", enabled);
	end)
	Events.active (self.gui, function(enabled, input)
		if (not self._validForActive (input)) then return end;
		self:_activate ("active", enabled);
	end)
end

-- *** PRIVATE METHODS *** --
function GuiClass:_activate (class, enabled)
	if (enabled) then
		self.css:addClass (class, self.animate)
	else
		self.css:removeClass (class, self.animate)
	end
end

function GuiClass._validForActive (input)
	local it = input.UserInputType;
	return (it == Enum.UserInputType.MouseButton1
		   or it == Enum.UserInputType.Touch)
end

return Object.new (GuiClass);
