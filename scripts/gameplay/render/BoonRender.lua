
BoonRender = Engine.RegisterUIRenderSystem("Boon Render")
local chars = { 'E', 'D', 'F', 'H', '@', 'L', 'H', '.', '/', '%', '&' }

function BoonRender:ShouldRender()
	return BoonWindow ~= nil and BoonWindow.open
end

local Min = math.min
local Max = math.max

function BoonRender.Render(ui)
	local bw = BoonWindow
	local colors = CompColors[bw.type]
	local fg, bg = colors[1], colors[2]
	
	if bw.seal then
		fg, bg = Colors.White, Colors.Black
	end

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

	local max, current = Input.HoldRatio("Take")
	local norm = current / max
	local nc = LerpColor(bgs[2], Colors.White, norm * norm)
	ui.ClearBox(x, y, w, h)
	ui.FillRect(x, y, w, h, nc)

	for i = 1, 250 do
		local c = LerpColor(fg, nc, Max(Rand:F01(), 0.25 + Rand:F01() * 0.5 - norm))
		local ch = chars[Rand:Range(1, #chars)]
		Engine.Glyph(x + 1 + Rand:Range(0, w - 1), y + 1 + Rand:Range(0, h - 1), ch, { fg = c, bg = nc }, "UI")
	end
	for i = 1, 150 do
		local c = LerpColor(fg, nc, Max(Rand:F01(), 0 + Rand:F01() * 0.5 - norm))
		local ch = chars[Rand:Range(1, #chars)]
		Engine.Glyph(x + 1 + Rand:Range(0, w - 1), y + 1 + Rand:Range(0, h - 1), ch, { fg = c, bg = nc }, "UI")
	end

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
			if bw.seal then
				ui.PushStyle(Colors.White, nc)
				ui.Label(" THE ROYAL SEAL")
				
				ui.Space(5)
				ui.Glyphs({ 
					"empty", "empty", "empty", "empty", "empty", "empty", "empty", "uptilde"
				})
				ui.Label("      ~Q~")
				ui.Glyphs({ 
					"empty", "empty", "empty", "empty", 
					"empty", "empty", "empty", "altar"
				})
				ui.Space(4)
				ui.Label("    GRASP IT")
				ui.Label("  AND DESCEND!")
				ui.Bar("", current, max, { width = 14 })
				ui.PopStyle()
			else
				ui.PushStyle(Colors.White, nc)
				ui.Label("THE " .. string.upper(bw.type) .. " GLYPH")
				ui.Space(5)
				ui.Glyphs({ 
					"empty", "empty", "empty", "empty", "empty", "empty", "empty", "uptilde"
				})
				ui.Label("      ~" .. string.sub(bw.type, 1, 1) .. "~")
				ui.Glyphs({ 
					"empty", "empty", "empty", "empty", 
					"empty", "empty", "empty", "altar"
				})
				ui.Space(4)
				ui.Label("    GRASP IT")
				ui.Label("  AND DESCEND!")
				ui.Bar("", current, max, { width = 14 })
				ui.PopStyle()
			end
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(x + 9, y + 23, w, h)
		ui.PushOrder("|")
			ui.PushStyle(LerpColor(Colors.White, fg, Max(norm, 0.2)), nc)
				ui.Label("HOLD <SPACE> OR PRESS <ESC>")
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()

end