DebugEntitySpawnRenderSystem = Engine.RegisterUIRenderSystem("Debug Spawn Render")

function DebugEntitySpawnRenderSystem:ShouldRender()
	return DebugToggle_EntitySpawn
end

function DebugEntitySpawnRenderSystem.Render(ui)
	local contents = DebugSpawnUI[Contents].items
	local selection = DebugSpawnUI[Selection].value

	ui.PushBox(39, 1, 20, 40)
		ui.PushOrder("|")
			ui.PushStyle(Colors.DarkCyan, Colors.Black)
			ui.List(contents, selection, function(e)
				ui.Label(e.name)
			end)
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()
end