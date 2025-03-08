local TopLevelRenderSystem = Engine.RegisterRenderSystem("Top Level Render")

local function Draw(query)
	for _, e in World:Exec(query):Iterator() do
		local lvl = e[InLevel]
		local ok = true
		if e ~= PlayerEntity then
			if lvl ~= nil and lvl.value < Level then
				RemoveEntityFromDungeon(e)
				World:Remove(e)
				ok = false
			end
		end

		if ok then
			local pos = e[Position]
			if (Dungeon.visibility:Get(pos.x, pos.y) or PlayerEntity[Telepathic]) and not e[Invisible] then
				local glyph = e[Glyph]
				Engine.Glyph(pos.x, pos.y, glyph.name)
			end
		end
	end
end

function TopLevelRenderSystem:ShouldRender()
	return Dungeon ~= nil and PlayerEntity ~= nil
end

function TopLevelRenderSystem:Render()
	Draw(ECS.Query.All(Glyph, Position).None(Player, Item, Creature))
	Draw(ECS.Query.All(Glyph, Position, Magic))
	Draw(ECS.Query.All(Glyph, Position, Item))
	Draw(ECS.Query.All(Glyph, Position, Creature))
	Draw(ECS.Query.All(Glyph, Position, Player))
end
