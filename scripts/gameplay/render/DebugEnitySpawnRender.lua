DebugEnitySpawnRenderSystem = Engine.RegisterRenderSystem()

function DebugEnitySpawnRenderSystem:Render()
	if DebugToggle_EntitySpawn then
		local itemList = DebugSpawnLibrary
		local widget = UI[DebugSpawnerWidget]

		widget.size = TableLength(itemList)

		local j = widget.top
		for key, entry in pairs(itemList) do
			local index = widget.left;
			local bgColor  = Colors.DarkCyan
			if j == widget.selected then bgColor = Colors.Yellow else bgColor = Colors.DarkCyan end
			local fgColor = Colors.Black
			Engine.Write(index, j, key,  fgColor,  bgColor, "UI")

			index = #key + widget.left
			for i= index,  widget.left + widget.width do
				Engine.Glyph(i, j, "empty",{ fg = Colors.Red, bg = Colors.DarkCyan }, "UI")
			end

			j = j + 1
		end
	end
end

function DebugEnitySpawnRenderSystem:Restore()
	local widget = UI[DebugSpawnerWidget]
	for i = widget.left, widget.left + widget.width do
		for j = widget.top, widget.top + widget.height do
			Engine.Glyph(i, j, "invalid",  { fg = Colors.Red, bg = Colors.Black}, "UI")
		end
	end

	widget.size = 0
end

