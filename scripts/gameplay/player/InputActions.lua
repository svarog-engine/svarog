
-- DEFAULT

Engine.RegisterInputSystem({ Action_Default_Wait }, function(input)
	World:Exec(ECS.Query.All(Player)):ForEach(function(entity)
		PlayerDone = true
	end)
end)

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
		PlayerDone = true
	end)
end)

Engine.RegisterInputSystem({ Action_Default_ZoomIn }, function()
	local currentSize = Config.FontSize
	local maxSize = Config.FontMaxSize
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

Engine.RegisterInputSystem({ Action_Default_ZoomOut }, function() 
	local currentSize = Config.FontSize
	local minSize = Config.FontMinSize
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

Engine.RegisterInputSystem({ Action_Default_Reload }, function() Svarog.Instance:Reload() end)

DebugToggle_Dijkstra = false
Engine.RegisterInputSystem({ Action_Default_DebugDijkstra }, function()
	DebugToggle_Dijkstra = not DebugToggle_Dijkstra
end)

InventoryOpen = false
Engine.RegisterInputSystem({ Action_Default_Inventory}, function()
	InventoryOpen = true
	Input.Push("Inventory")
end)

Engine.RegisterInputSystem({Action_Inventory_Exit}, function()
	Input.Pop()
	InventoryOpen = false
	InventoryRender:Restore()
end)