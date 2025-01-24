
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()
	
	local map = DungeonEntity[Dungeon].map
	for _, k in map:Iterate() do
		local tile = map.tiles[k]
		local char = " "
		if tile.value.type == Floor then
			char = "."
		elseif tile.value.type == Door then
			char = "+"
		end
		Engine.Glyph(tile.x, tile.y, char, Colors.White, Colors.Black)
	end

	for _, e in World:Exec(ECS.Query.All(Player, Position)):Iterator() do
		local pos = e[Position]
		Engine.Glyph(pos.x, pos.y, "@", Colors.Yellow, Colors.Black)
	end
end

