
LootRender = Engine.RegisterUIRenderSystem("Loot Render")

local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i" }

function LootRender:ShouldRender()
	return LootTable[LootInventory].target ~= nil
end

function LootRender.Render(ui)
	local lootEntity = LootTable[LootInventory].target
	local loot = lootEntity[Contents].items
	local x, y = 24, 25
	ui.ClearBox(x, y, 20, 10)
	ui.FillRect(x, y, 20, 10, Colors.Gray)

	ui.PushBox(x, y, 20, 10)
		ui.PushOrder("-")
			ui.PushStyle(Colors.LightGray, Colors.DarkGray)
				ui.Glyphs({ 
					"full_tile", "full_tile", "full_tile", "full_tile", 
					"full_tile", "full_tile", "full_tile", "full_arrow" 
				})
			ui.PopStyle()
			ui.PushStyle(Colors.DarkGray, Colors.Black)
				ui.Glyphs({ 
					"full_tile", "full_tile", "full_tile", "full_tile", 
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"half_tile"
				})
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()

	for i = 1, 10 do
		ui.PushBox(x, y + i, 1, 1)
			ui.PushStyle(Colors.LightGray, Colors.Gray)				
				ui.Glyphs({ "half_tile" })
			ui.PopStyle()
		ui.PopBox()

		ui.PushBox(x + 20, y + i, 1, 1)
			ui.PushStyle(Colors.DarkGray, Colors.Black)
				ui.Glyphs({ "half_tile" })
			ui.PopStyle()
		ui.PopBox()
	end

	ui.PushBox(x + 1, y, 20, 10)
		ui.PushStyle(Colors.DarkGray, Colors.LightGray)
			ui.Label("Loot")
		ui.PopStyle()
	ui.PopBox()

	ui.PushBox(x + 1, y + 1, 20, 10)
		ui.PushOrder("|")
			ui.Space(1)

			for i, item in ipairs(loot) do
				local fg = Colors.White
				local bg = Colors.Gray
				if not Contents.HasSpace(PlayerEntity, item.itemId) then
					fg = Colors.Red
				end

				ui.PushStyle(fg, bg)
					ui.Label(letters[i] .. "] " .. ItemLibrary[item.itemId].name .. " (" .. item.quantity .. ") ")
				ui.PopStyle()
			end
		ui.PopOrder()
	ui.PopBox()	
end