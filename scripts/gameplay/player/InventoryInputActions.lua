-- DEFAULT

InventoryOpen = false
Engine.RegisterInputSystem({ Action_Default_Inventory }, function()
	InventoryOpen = true
	local widget = UI[InventoryWidget]
	widget.source = PlayerEntity[Inventory]
	widget.selected = 1
	Input.Push("Inventory")
end)

Engine.RegisterInputSystem({ Action_Inventory_Exit }, function()
	Input.Pop()
	InventoryOpen = false
	InventoryRender:Restore()
end)

Engine.RegisterInputSystem({ Action_Inventory_SelectNext }, function()
	local widget = UI[InventoryWidget]
	local newSelected = widget.selected + 1

	if newSelected <= #widget.source.items then
		widget.selected = widget.selected + 1
	end
end)

Engine.RegisterInputSystem({ Action_Inventory_SelectPrevious }, function()
	local widget = UI[InventoryWidget]
	local newSelected = widget.selected - 1

	if newSelected > 0 then
		widget.selected = widget.selected - 1
	end
end)

Engine.RegisterInputSystem({ Action_Inventory_Drop }, function()
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

Engine.RegisterInputSystem({ Action_Inventory_Throw }, function()
	local selection = InventoryWidget.GetSelected()
	if selection == nil then
		return
	end

	local callback = {
		callback = function(x, y)
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
	}

	TargetOverlayEntity:Set(ActivateTargetOverlay{ callback = entry })
end)
