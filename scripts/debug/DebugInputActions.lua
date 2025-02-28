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

DebugToggle_EntitySpawn = false
Engine.RegisterInputSystem({ Action_Default_DebugSpawn }, function()
	DebugToggle_EntitySpawn = true
	Input.Push("DebugSpawn")
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Select }, function()

	local selection = DebugUI[DebugSpawnerWidget].selected

	local i = 1
	local entry = nil
	for _, e in pairs(DebugSpawnLibrary) do
		if i == selection then
			entry = e
		end
		i = i + 1
	end

	if entry == nil then
		return
	end

	local callback = {
		callback = function(x, y, data)
			local selectedEntity  = data.entity
			selectedEntity(x,y)
		end
		,
		data = { entity = entry }
	}

	local playerPosition = PlayerEntity[Position]
	TargetRenderSystem:Activate(callback, playerPosition.x, playerPosition.y)
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Up }, function()
	local widget = DebugUI[DebugSpawnerWidget]
	local newSeleced = widget.selected - 1

	if newSeleced > 0 then
		widget.selected = widget.selected - 1
	end
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Down }, function()
	local widget = DebugUI[DebugSpawnerWidget]
	local newSeleced = widget.selected + 1

	if newSeleced <= widget.size then
		widget.selected = widget.selected + 1
	end
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Reload }, function()
	Svarog:RunScriptFileIfExists("scripts\\debug\\DebugSpawnLibrary")
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Exit }, function()
	DebugToggle_EntitySpawn = false
	DebugEnitySpawnRenderSystem:Restore()
	Input.Pop()
end)