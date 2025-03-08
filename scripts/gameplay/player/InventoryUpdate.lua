
local InventoryToggleSystem = Engine.RegisterPlayerSystem("Inventory Toggle")

local Actions = {
	drop = function(details)
		local x = details.x or PlayerEntity[Position].x
		local y = details.y or PlayerEntity[Position].y
		local selection = InventoryEntity[Selection].value
		local contents = PlayerEntity[Contents].items
		local item = contents[selection]
		local itemMeta = ItemLibrary[item.itemId]

		World:Entity(
			Item{ id = item.itemId, quantity = item.quantity},
			Position{ x = x, y = y },
			Name { value = itemMeta.name },
			Glyph{ name = itemMeta.glyph })

		Contents.Remove(PlayerEntity, item.itemId, item.quantity)
		Diary.Write("You drop a " .. itemMeta.name .. ".")
		while selection > #contents do
			selection = selection - 1
		end

		InventoryEntity:Set(DeactivateInventoryOverlay())
	end,

	cast = function(details)
		local x = details.x or PlayerEntity[Position].x
		local y = details.y or PlayerEntity[Position].y
		local selection = InventoryEntity[Selection].value
		local contents = PlayerEntity[Contents].items
		local item = contents[selection]
		local itemMeta = ItemLibrary[item.itemId]

		local actionDone = false
		if CanCast(item.itemId) then
			Cast(x, y, item.itemId)
			actionDone = true
		end

		if actionDone then 
			Contents.Remove(PlayerEntity, item.itemId, 1)
			while selection > #contents do
				selection = selection - 1
			end

			InventoryEntity:Set(DeactivateInventoryOverlay())
			PlayerDone = true
		end
	end,

	consume = function(details)
		local selection = InventoryEntity[Selection].value
		local contents = PlayerEntity[Contents].items
		local item = contents[selection]
		if item == nil then return end
		local itemMeta = ItemLibrary[item.itemId]

		local actionDone = false
		if CanConsume(item.itemId) then
			if Consume(item.itemId) then
				Diary.Write("You consume the " .. itemMeta.name .. ". It alleviates some tension.")
			else
				Diary.Write("You consume the " .. itemMeta.name .. ", but it doesn't sate your glyphs.")
			end
			actionDone = true
		end

		if actionDone then 
			Contents.Remove(PlayerEntity, item.itemId, 1)
			while selection > #contents do
				selection = selection - 1
			end

			InventoryEntity:Set(DeactivateInventoryOverlay())
			PlayerDone = true
		end
	end,
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