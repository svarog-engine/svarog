Engine.RegisterInputSystem({ Action_Default_Inventory }, function()
	InventoryEntity:Set(ActivateInventoryOverlay())
end)

Engine.RegisterInputSystem({ Action_Inventory_Exit }, function()
	InventoryEntity:Set(DeactivateInventoryOverlay())
end)

Engine.RegisterInputSystem({ Action_Inventory_SelectPrevious }, function()
	SelectPrev(InventoryEntity, #PlayerEntity[Contents].items)
end)

Engine.RegisterInputSystem({ Action_Inventory_SelectNext }, function()
	SelectNext(InventoryEntity, #PlayerEntity[Contents].items)
end)

Engine.RegisterInputSystem({ Action_Inventory_Drop }, function()
	InventoryEntity:Set(DoInventoryAction{ action = "drop" })
end)

Engine.RegisterInputSystem({ Action_Inventory_Throw }, function()
	TargetOverlayEntity:Set(ActivateTargetOverlay{ 
		callback = function(x, y)
			InventoryEntity:Set(DoInventoryAction{ action = "drop", details = { x = x, y = y }})
		end
	})
end)
