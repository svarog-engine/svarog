
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()
	for _, e in World:Exec(ECS.Query.All(Dungeon)):Iterator() do
		local map = e[Dungeon].map
		for _, tile in ipairs(map) do
			Engine.Glyph(tile.x, tile.y, tile.type, Colors.White, Colors.Black)
		end
	end

	for _, e in World:Exec(ECS.Query.All(Player, Position)):Iterator() do
		local pos = e[Position]
		Engine.Glyph(pos.x, pos.y, "@", Colors.Yellow, Colors.Black)
	end
end

