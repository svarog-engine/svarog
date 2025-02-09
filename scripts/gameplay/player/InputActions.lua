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
		PerformBump(entity, pos.x, pos.y, dx, dy)
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

-- Debug

DebugToggle_Distances = false
DebugToggle_PrintDistances = false

Engine.RegisterInputSystem({ Action_Default_DebugDistances }, function()
	DebugToggle_Distances = not DebugToggle_Distances
end)

Engine.RegisterInputSystem({ Action_Default_DebugPrintDistances }, function()
	DebugToggle_PrintDistances = not DebugToggle_PrintDistances
end)

-- true or false by default?
DebugToggle_FOV = false
Engine.RegisterInputSystem({ Action_Default_DebugFOV }, function()
	DebugToggle_FOV = not DebugToggle_FOV

	if DebugToggle_FOV then
		Dungeon.visibility:Reset(0)
		Dungeon.visited:Reset(0)
	else
		Dungeon.visibility:Reset(0)
		Dungeon.visited:Reset(1)
	end
end)

-- Inventory

InventoryOpen = false
Engine.RegisterInputSystem({ Action_Default_Inventory}, function()
	InventoryOpen = true
	local widget = UI[InventoryWidget]
	widget.source = PlayerEntity[Inventory]
	widget.selected = 1
	Input.Push("Inventory")
end)

Engine.RegisterInputSystem({Action_Inventory_Exit}, function()
	Input.Pop()
	InventoryOpen = false
	InventoryRender:Restore()
end)

Engine.RegisterInputSystem({Action_Inventory_SelectNext}, function()
	local widget = UI[InventoryWidget]
	local newSeleced = widget.selected + 1

	if newSeleced <= #widget.source.items then
		widget.selected = widget.selected + 1
	end
end)

Engine.RegisterInputSystem({Action_Inventory_SelectPrevious}, function()
	local widget = UI[InventoryWidget]
	local newSeleced = widget.selected - 1

	if newSeleced > 0 then
		widget.selected = widget.selected - 1
	end
end)

Engine.RegisterInputSystem({Action_Inventory_Drop}, function()
	local selection = InventoryWidget.GetSelected()
	if selection == nil then
		return
	end

	Inventory.Remove(PlayerEntity, selection)

	local widget = UI[InventoryWidget]
	widget.selected = 0

	local dropPosition = PlayerEntity[Position]

	local itemMeta = ItemLibrary[selection]

	World:Entity(
	Item{id = selection},
	Position{x = dropPosition.x, y = dropPosition.y},
	Glyph{name = itemMeta.glyph})
end)

Engine.RegisterInputSystem({Action_Inventory_Throw}, function()
	local selection = InventoryWidget.GetSelected()
	if selection == nil then
		return
	end

	local callback = {
		callback = function(x, y, data)
			local selection  = data.item
			Inventory.Remove(PlayerEntity, selection)

			local widget = UI[InventoryWidget]
			widget.selected = 0

			local target = UI[TargetOverlay]

			local itemMeta = ItemLibrary[selection]

			World:Entity(
			Item{id = selection},
			Position{x = target.x, y = target.y},
			Glyph{name = itemMeta.glyph})

			Diary.Write("Dropped " .. ItemLibrary[selection].name .. ".")
		end
		,
		data = { item = selection }
	}

	local playerPosition = PlayerEntity[Position]
	TargetRenderSystem:Activate(callback, playerPosition.x, playerPosition.y)
end)

Engine.RegisterInputSystem(
	{
		Action_TargetOverlay_Left, 
		Action_TargetOverlay_Right, 
		Action_TargetOverlay_Up, 
		Action_TargetOverlay_Down
	}, function(input)
		local dxl = input[Action_TargetOverlay_Left] and -1 or 0
		local dxr = input[Action_TargetOverlay_Right] and 1 or 0
		local dyl = input[Action_TargetOverlay_Up] and -1 or 0
		local dyr = input[Action_TargetOverlay_Down] and 1 or 0

		TargetRenderSystem:UpdatePosition(dxl + dxr, dyl + dyr)
end)

Engine.RegisterInputSystem({Action_TargetOverlay_Exit}, function()
	TargetRenderSystem:Deactivate(true)
end)

Engine.RegisterInputSystem({Action_TargetOverlay_Confirm}, function()
	TargetRenderSystem:Deactivate(false)
end)