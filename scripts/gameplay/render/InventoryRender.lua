
InventoryRender = Engine.RegisterUIRenderSystem("Inventory Render")

function InventoryRender:ShouldRender()
	return InventoryEntity[Open] ~= nil
end

function InventoryRender.Render(ui)
	ui.PushBox(46, 25, 20, 10)
		ui.PushOrder("|")
			ui.Label("= INVENTORY =")
			ui.Space(1)
			ui.List(PlayerEntity[Contents].items, InventoryEntity[Selection].value, function(v) 
				ui.Label(ItemLibrary[v.itemId].name .. " (" .. tostring(v.quantity) .. ")")
			end )
		ui.PopOrder()


	ui.PopBox()

	ui.ClearBox(45, 35, 20, 2)
	ui.PushBox(45, 35, 20, 2)
		ui.PushOrder("|")
			local selection = InventoryEntity[Selection].value
			for i, item in ipairs(PlayerEntity[Contents].items) do
				if i == selection then
					ui.Label("[D]rop")

					if CanConsume(item.itemId) then
						ui.Label("[C]onsume")
					end

					if CanCast(item.itemId) then
						ui.Label("[C]ast")
					end
				end
			end
		ui.PopOrder()
	ui.PopBox()
end