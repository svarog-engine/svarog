
BoonRender = Engine.RegisterUIRenderSystem("Boon Render")

function BoonRender:ShouldRender()
	return BoonWindow ~= nil and BoonWindow.open
end

function BoonRender.Render(ui)
	local bw = BoonWindow
	
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
			ui.Label("Boon")
		ui.PopStyle()
	ui.PopBox()
end