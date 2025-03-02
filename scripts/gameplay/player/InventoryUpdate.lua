
local InventoryToggleSystem = Engine.RegisterPlayerSystem("Inventory Toggle")

local Actions = {
	drop = function(details)
		local x = details.x or PlayerEntity[Position].x
		local y = details.y or PlayerEntity[Position].y
		local selection = InventoryEntity[Selection].value
		local contents = PlayerEntity[Contents].items
		local item = contents[selection]
		local itemMeta = ItemLibrary[item]

		World:Entity(
			Item{ id = item },
			Position{ x = x, y = y },
			Glyph{ name = itemMeta.glyph })

		table.remove(contents, selection)
		Diary.Write("Dropped " .. itemMeta.name .. ".")
		while selection > #contents do
			selection = selection - 1
		end

		InventoryEntity:Set(DeactivateInventoryOverlay())
	end
}

function InventoryToggleSystem:ShouldTick()
	return InventoryEntity[ActivateInventoryOverlay] ~= nil or 
		   InventoryEntity[DeactivateInventoryOverlay] ~= nil or
		   InventoryEntity[DoInventoryAction] ~= nil
end

function InventoryToggleSystem:Tick()
	local activate = InventoryEntity[ActivateInventoryOverlay]
	local deactivate = InventoryEntity[DeactivateInventoryOverlay]
	local doAction = InventoryEntity[DoInventoryAction]

	if activate ~= nil then
		InventoryEntity:Set(Open())
		InventoryEntity:Unset(ActivateInventoryOverlay)
		if InventoryEntity[Selection].value == 0 and #PlayerEntity[Contents].items > 0 then
			InventoryEntity[Selection].value = 1
		end
		Input.Push("Inventory")
	elseif deactivate ~= nil then
		InventoryEntity:Unset(Open)
		InventoryEntity:Unset(DeactivateInventoryOverlay)
		UIRenderer.Clear()
		Input.Pop()
	elseif doAction ~= nil then
		local action = Actions[doAction.action]
		if action ~= nil then
			action(doAction.details)
		end
		InventoryEntity:Unset(DoInventoryAction)
	end
end