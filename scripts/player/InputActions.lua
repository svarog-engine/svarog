
-- DEFAULT

Engine.RegisterInputSystem(
	{
		Action_Default_Left, 
		Action_Default_Right, 
		Action_Default_Up, 
		Action_Default_Down
	}, function(input)

	World:Exec(ECS.Query.All(Player, Position)):ForEach(function(entity)
		local dxl = input[Action_Default_Left] and -1 or 0
		local dxr = input[Action_Default_Right] and 1 or 0
		local dyl = input[Action_Default_Up] and -1 or 0
		local dyr = input[Action_Default_Down] and 1 or 0
		local dx = dxl + dxr
		local dy = dyl + dyr
		local pos = entity[Position]
		entity:Set(Bump({ x = pos.x, y = pos.y, dx = dx, dy = dy }))
	end)
end)

Engine.RegisterInputSystem({Action_Default_IncreaseFontSize}, function()
	local currentSize = Config.FontSize
	local maxSize = Config.MaxFontSize
	local step = Config.FontChangeStep

	if currentSize < maxSize then
		if currentSize + step > maxSize then
			Config.FontSize = maxSize
		else
			Config.FontSize = currentSize + step
		end

		Svarog.Instance:ReloadPresenter()
	end
end)

Engine.RegisterInputSystem({Action_Default_DecreaseFontSize}, function() 
	local currentSize = Config.FontSize
	local minSize = Config.MinFontSize
	local step = Config.FontChangeStep

	if currentSize > minSize then
		if currentSize - step < minSize then
			Config.FontSize = minSize
		else
			Config.FontSize = currentSize - step
		end

		Svarog.Instance:ReloadPresenter()
	end
end)

-- DEBUG

Engine.RegisterInputSystem({ Action_Default_Debug }, function() 
	Input.Push("Debug") 
end)

Engine.RegisterInputSystem({ Action_Debug_Back }, function() Input.Pop() end)
Engine.RegisterInputSystem({ Action_Debug_Reload }, function() Svarog.Instance:Reload() end)