local player = game.Players.LocalPlayer

function getScreenSize ()
	local mouse = player:GetMouse ()
	return {
		X = mouse.ViewSizeX,
		Y = mouse.ViewSizeY
	};
end

return getScreenSize