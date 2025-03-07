
local VFXRenderSystem = Engine.RegisterRenderSystem("Burning Render")

local neighbors = { { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 } }
local defaultBurnColors = { Colors.Yellow, Colors.Red }
local defaultMagicColors = { Colors.LightMagenta, Colors.DarkMagenta }

function VFXRenderSystem:Render()
	for _, entity in World:Exec(ECS.Query.All(Burning, Position)):Iterator() do
		local burn = entity[Burning]
		if burn.speed == nil then burn.speed = 0.6 + (Rand:F01() - 0.5) / 10.0 end
		
		local pos = entity[Position]
		local f = (math.sin(burn.value) + 1.0) * 0.5
		local burnColors = burn.colors or defaultBurnColors

		local bg = Colors:Lerp(burnColors[1], burnColors[2], f)
		burn.value = burn.value + burn.speed
		if Dungeon.visibility:Get(pos.x, pos.y) then
			Engine.Bg(pos.x, pos.y, bg)
		end

		for _, neighbor in ipairs(neighbors) do
			local x, y = pos.x + neighbor[1], pos.y + neighbor[2]
			if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
				local tile = Dungeon.floor:Get(x, y)
				if tile.type == Wall then
					Engine.Bg(x, y, Colors:Lerp(bg, Colors.Black, 0.5))
				elseif tile.type == Floor then
					Engine.Fg(x, y, Colors:Lerp(bg, Colors.White, 0.5))
				end
			end
		end
	end

	for _, entity in World:Exec(ECS.Query.All(Magic, Position)):Iterator() do
		local magic = entity[Magic]
		if magic.speed == nil then magic.speed = 0.6 + (Rand:F01() - 0.5) / 10.0 end
		local d = (Rand:F01() - 0.5) / 10.0
		local pos = entity[Position]
		local f = (math.sin(magic.value) + 1.0) * 0.5
		local magicColors = magic.colors or defaultMagicColors
		local fg = Colors:Lerp(defaultBurnColors[1], defaultBurnColors[2], f + d)
		local bg = Colors:Lerp(magicColors[1], magicColors[2], f - d)
		magic.value = magic.value + magic.speed
		
		if Dungeon.visibility:Get(pos.x, pos.y) then
			Engine.Glyph(pos.x, pos.y, entity[Glyph].glyph)
			Engine.Bg(pos.x, pos.y, bg)
			Engine.Fg(pos.x, pos.y, fg)
		else
			Engine.Glyph(pos.x, pos.y, entity[Glyph].glyph)
			Engine.Bg(pos.x, pos.y, Colors:Lerp(bg, Colors.Black, 0.5))
			Engine.Fg(pos.x, pos.y, Colors:Lerp(fg, Colors.Black, 0.5))
		end

		for _, neighbor in ipairs(neighbors) do
			local x, y = pos.x + neighbor[1], pos.y + neighbor[2]
			if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
				local tile = Dungeon.floor:Get(x, y)
				if tile.type == Wall then
					Engine.Bg(x, y, Colors:Lerp(bg, Colors.Black, 0.5))
				elseif tile.type == Floor then
					Engine.Fg(x, y, Colors:Lerp(bg, Colors.White, 0.5))
				end
			end
		end
	end
end

