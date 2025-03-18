
local function TakeLoot(n)
	local lootEntity = LootTable[LootInventory].target
	local loot = lootEntity[Contents].items
	local playerBag = PlayerEntity[Contents].items
	if loot == nil then return end
	if n > #loot then return end
	
	local item = loot[n]
	if not Contents.HasSpace(PlayerEntity, item.itemId) then
		Diary.Write("Not enough space to consider carrying this...")
		return
	end

	Contents.Add(PlayerEntity, item.itemId, item.quantity)
	Contents.Remove(lootEntity, item.itemId, item.quantity)

	if #loot == 0 then
		lootEntity:Unset(Contents)
		lootEntity[Glyph].name = lootEntity[Glyph].name .. "_empty"
		toggled = {}
		LootTable[LootInventory].target = nil
		Input.Pop()
		UIRenderer.Clear()
	end
end

Engine.RegisterInputSystem({ Action_Loot_Exit }, function()
	toggled = {}
	LootTable[LootInventory].target = nil
	Input.Pop()
	UIRenderer.Clear()
end)

Engine.RegisterInputSystem({ Action_Loot_A }, function()
	TakeLoot(1)
end)

Engine.RegisterInputSystem({ Action_Loot_B }, function()
	TakeLoot(2)
end)

Engine.RegisterInputSystem({ Action_Loot_C }, function()
	TakeLoot(3)
end)

Engine.RegisterInputSystem({ Action_Loot_D }, function()
	TakeLoot(4)
end)

Engine.RegisterInputSystem({ Action_Loot_E }, function()
	TakeLoot(5)
end)

Engine.RegisterInputSystem({ Action_Loot_F }, function()
	TakeLoot(6)
end)

Engine.RegisterInputSystem({ Action_Loot_G }, function()
	TakeLoot(7)
end)

Engine.RegisterInputSystem({ Action_Loot_H }, function()
	TakeLoot(8)
end)

Engine.RegisterInputSystem({ Action_Loot_I }, function()
	TakeLoot(9)
end)