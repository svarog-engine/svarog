local TopLevelRenderSystem = Engine.RegisterRenderSystem()

local function Draw(query)
	for _, e in World:Exec(query):Iterator() do
		local pos = e[Position]
		local glyph = e[Glyph]
		Engine.Glyph(pos.x, pos.y, glyph.name)
	end
end

function TopLevelRenderSystem:Render()
	Draw(ECS.Query.All(Glyph, Position, Item))
	Draw(ECS.Query.All(Glyph, Position, Creature))
	Draw(ECS.Query.All(Glyph, Position, Player))
end