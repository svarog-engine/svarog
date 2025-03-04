
InventoryRender = Engine.RegisterUIRenderSystem("Inventory Render")

function InventoryRender:ShouldRender()
	return InventoryEntity[Open] ~= nil
end

function InventoryRender.Render(ui)
	ui.PushBox(46, 10, 20, 20)
		ui.PushOrder("|")
			ui.Label("= INVENTORY =")
			ui.Space(1)
			ui.List(PlayerEntity[Contents].items, InventoryEntity[Selection].value)
		ui.PopOrder()
	ui.PopBox()
end