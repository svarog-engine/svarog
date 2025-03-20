
BoonRender = Engine.RegisterUIRenderSystem("Boon Render")

function BoonRender:ShouldRender()
	return BoonWindow ~= nil and BoonWindow.open
end

function BoonRender.Render(ui)
	local bw = BoonWindow
	local colors = CompColors[bw.type]
	local fg, bg = colors[1], colors[2]
	local fgs = {}
	local bgs = {}
	fgs[1] = LerpColor(fg, Colors.LightGray, 0.5)
	fgs[2] = LerpColor(fg, Colors.Gray, 0.5)
	fgs[3] = LerpColor(fg, Colors.DarkGray, 0.5)
	bgs[1] = LerpColor(bg, Colors.LightGray, 0.5)
	bgs[2] = LerpColor(bg, Colors.Gray, 0.5)
	bgs[3] = LerpColor(bg, Colors.DarkGray, 0.5)
	local x, y = 7, 8
	local w, h = 47, 25
	ui.ClearBox(x, y, w, h)
	ui.FillRect(x, y, w, h, bgs[2])

	ui.PushBox(x, y, w, h)
		ui.PushOrder("-")
			ui.PushStyle(fgs[1], bgs[3])
				ui.Glyphs({ 
					"full_tile", "full_tile", "full_tile", "full_tile", 
					"full_tile", "full_tile", "full_tile", "full_arrow" 
				})
			ui.PopStyle()
			ui.PushStyle(fgs[3], bgs[3])
				ui.Glyphs({ 
					"full_tile", "full_tile", "full_tile", "full_tile", 
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile", 
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "full_tile",
					"full_tile", "full_tile", "full_tile", "half_tile"
				})
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()

	for i = 1, h do
		ui.PushBox(x, y + i, 1, 1)
			ui.PushStyle(fg, bg)
				ui.Glyphs({ "half_tile" })
			ui.PopStyle()
		ui.PopBox()

		ui.PushBox(x + w, y + i, 1, 1)
			ui.PushStyle(fgs[3], bgs[3])
				ui.Glyphs({ "half_tile" })
			ui.PopStyle()
		ui.PopBox()
	end

	for i = x + 2, x + w - 1 do
		ui.PushBox(i, y + h, 1, 1)
			ui.PushStyle(fgs[3], bgs[3])
				ui.Glyphs({ "full_tile" })
			ui.PopStyle()
		ui.PopBox()
	end

	ui.PushBox(x + 1, y + h, 1, 1)
		ui.PushStyle(fg, bg)
			ui.Glyphs({ "full_tile" })
		ui.PopStyle()
	ui.PopBox()

	ui.PushBox(x + 15, y + 5, w, h)
		ui.PushOrder("|")
			ui.PushStyle(Colors.White, bgs[2])
			ui.Label("THE " .. string.upper(bw.type) .. " GLYPH")
			ui.Space(4)
			ui.Label("    GRASP IT!    ")
			local holdProgress = Input.HoldRatio("Take")
			ui.Bar("", holdProgress.current, holdProgress.maximum, { width = 20 })
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()
end