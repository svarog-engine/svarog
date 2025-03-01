
local FadeOutRenderSystem = Engine.RegisterRenderSystem("Fadeout Render")

function FadeOutRenderSystem:Render()
	for _, entity in World:Exec(ECS.Query.All(FadeOut, Glyph, Position)):Iterator() do
		local glyph = entity[Glyph]
		local fadeout = entity[FadeOut]
		local pos = entity[Position]

		bg = Colors:Lerp(fadeout.start, fadeout.target, fadeout.time)
		fadeout.time = fadeout.time + fadeout.speed

		Engine.Glyph(pos.x, pos.y, glyph.name, { bg = bg })

		if fadeout.time > 1.0 then
			entity:Unset(FadeOut)
		end
	end
end

