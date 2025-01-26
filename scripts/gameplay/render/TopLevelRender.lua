local TopLevelRenderSystem = Engine.RegisterRenderSystem()

function TopLevelRenderSystem:Render()
	for _, e in World:Exec(ECS.Query.All(Glyph, Position).Any(Player, Creature, Item)):Iterator() do
		local pos = e[Position]
		local glyph = e[Glyph]
		Engine.Glyph(pos.x, pos.y, glyph.name)
	end
end