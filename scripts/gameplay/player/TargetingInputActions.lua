
Engine.RegisterInputSystem(
	{
		Action_TargetOverlay_Left, 
		Action_TargetOverlay_Right, 
		Action_TargetOverlay_Up, 
		Action_TargetOverlay_Down
	}, function(input)
		local dxl = input[Action_TargetOverlay_Left] and -1 or 0
		local dxr = input[Action_TargetOverlay_Right] and 1 or 0
		local dyu = input[Action_TargetOverlay_Up] and -1 or 0
		local dyd = input[Action_TargetOverlay_Down] and 1 or 0

		TargetOverlayEntity[Position].x = TargetOverlayEntity[Position].x + dxl + dxr
		TargetOverlayEntity[Position].y = TargetOverlayEntity[Position].y + dyu + dyd
end)

Engine.RegisterInputSystem({Action_TargetOverlay_Exit}, function()
	TargetOverlayEntity:Set(DeactivateTargetOverlay{ success = false })
end)

Engine.RegisterInputSystem({Action_TargetOverlay_Confirm}, function()
	TargetOverlayEntity:Set(DeactivateTargetOverlay{ success = true })
end)

Engine.RegisterInputSystem({Action_TargetOverlay_MouseMove}, function()
	local x = InputStack.MouseX
	local y = InputStack.MouseY
	TargetOverlayEntity[Position].x = x
	TargetOverlayEntity[Position].y = y
end)

Engine.RegisterInputSystem({Action_TargetOverlay_MouseCofirm}, function()
	TargetOverlayEntity:Set(DeactivateTargetOverlay{ success = true })
end)