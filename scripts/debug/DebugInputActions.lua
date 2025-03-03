DebugToggle_Distances = { "player", "walls" }
DebugToggle_Distances[0] = nil

DebugToggle_DistanceIndex = 0
DebugToggle_PrintDistances = false

Engine.RegisterInputSystem({ Action_Default_DebugDistances }, function()
	DebugToggle_DistanceIndex = (DebugToggle_DistanceIndex + 1) % 5
end)

Engine.RegisterInputSystem({ Action_Default_DebugPrintDistances }, function()
	DebugToggle_PrintDistances = not DebugToggle_PrintDistances
end)

DebugToggle_FOV = true
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

Engine.RegisterInputSystem({ Action_Default_DebugSpawn }, function()
	DebugToggle_EntitySpawn = true
	Input.Push("DebugSpawn")
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Select }, function()
	local selection = DebugSpawnUI[Selection].value	
	local entry = DebugSpawnUI[Contents].items[selection]
	if entry ~= nil then
		TargetOverlayEntity:Set(ActivateTargetOverlay{ callback = entry.callback })
	end
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Up }, function()
	SelectPrev(DebugSpawnUI, #DebugSpawnUI[Contents].items)
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Down }, function()
	SelectNext(DebugSpawnUI, #DebugSpawnUI[Contents].items)
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Reload }, function()
	Svarog:RunScriptFileIfExists("scripts\\debug\\DebugSpawnLibrary")
end)

Engine.RegisterInputSystem({ Action_DebugSpawn_Exit }, function()
	DebugToggle_EntitySpawn = false
	UIRenderer.Clear()
	Input.Pop()
end)