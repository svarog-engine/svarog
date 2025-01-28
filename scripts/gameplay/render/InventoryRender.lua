
InventoryRender = Engine.RegisterRenderSystem()

function InventoryRender:Render()
	if InventoryOpen then
		RenderInventory()
		RenderSelection()
	end
end

function RenderInventory()
	if InventoryOpen then
		itemList = UI[InventoryWidget].source.items
		local widget = UI[InventoryWidget]
		local lineIndex = 1
		for j = widget.top, widget.top + widget.height do
			local index = widget.left;
			if lineIndex <= #itemList then
				local bgColor  = Colors.Green
				if lineIndex == widget.selected then bgColor = Colors.Yellow else bgColor = Colors.Green end
				local fgColor = Colors.Black
				local itemName = ItemLibrary[itemList[lineIndex]].name
				Engine.Write(index, j, itemName,  fgColor,  bgColor )
				index = #(itemList[lineIndex]) + widget.left
			end

			for i= index,  widget.left + widget.width do
				Engine.Glyph(i, j, " ", { fg = Colors.Red, bg = Colors.Green })
			end

			lineIndex = lineIndex + 1
		end
	end
end

function RenderSelection()
	-- TODO wrap text 
	local selection = InventoryWidget.GetSelected()
	if selection ~= nil then
		local itemPanel = UI[ItemDetailsPanelWidget]
		local itemDescription = ItemLibrary[selection].description
		local bgColor = Colors.LightBlue
		for j = itemPanel.top, itemPanel.top + itemPanel.height - 1 do
			local index = itemPanel.left
			local renderText = string.sub(itemDescription, 1, itemPanel.width)
			Engine.Write(index, j, renderText ,  Colors.Black, bgColor )
			index = index + #renderText
			for i= index,  itemPanel.left + itemPanel.width do
				Engine.Glyph(i, j, " ", { fg = Colors.Red, bg = bgColor })
			end
			
		end
	end
end

function InventoryRender:Restore()
	local inventoryWidget = UI[InventoryWidget]
	for i = inventoryWidget.left, inventoryWidget.left + inventoryWidget.width do
		for j = inventoryWidget.top, inventoryWidget.top + inventoryWidget.height do
			Engine.Glyph(i, j, " ", { fg = Colors.Red })
		end
	end

	local itemPanel = UI[ItemDetailsPanelWidget]
	for i = itemPanel.left, itemPanel.left + itemPanel.width do
		for j = itemPanel.top, itemPanel.top + itemPanel.height do
			Engine.Glyph(i, j, " ", { fg = Colors.Red })
		end
	end
end