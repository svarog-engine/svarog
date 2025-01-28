
InventoryRender = Engine.RegisterRenderSystem()

function InventoryRender:Render()
	if InventoryOpen then
		for _, entity in World:Exec(ECS.Query.All(Inventory)):Iterator() do
			local inv = entity[Inventory]
			itemList = inv.items
			local widget = Widgets.Inventory
			local lineIndex = 1
			for j = widget.top, widget.top + widget.height do
				local index = widget.left;
				if lineIndex <= #itemList then
					Engine.Write(index, j, itemList[lineIndex],  Colors.Black,  Colors.Green )
					index = #(itemList[lineIndex]) + widget.left
				end

				for i= index,  widget.left + widget.width do
					Engine.Glyph(i, j, " ", { fg = Colors.Red, bg = Colors.Green })
				end

				lineIndex = lineIndex + 1
			end
		end
	end
end

function InventoryRender:Restore()
	local widget = Widgets.Inventory
	for i = widget.left, widget.left + widget.width do
		for j = widget.top, widget.top + widget.height do
			Engine.Glyph(i, j, " ", { fg = Colors.Red })
		end
	end
end