local PlayerLightRenderSystem = Engine.RegisterRenderSystem()

function PlayerLightRenderSystem:Render()
	local map = Dungeon.map
	if map ~= nil then
		for _, e in World:Exec(ECS.Query.All(Player, Position)):Iterator() do
			local pos = e[Position]
			local levels = { "back_semi", "back_mid", "back_lit" }
			for i = -3, 3 do
				for j = -3, 3 do
					if not (i == 0 and j == 0) then 
						local d = 4 - math.floor(math.sqrt(i * i + j * j) + 0.5)
						if d < 4 and d > 0 then
							if map:Has(pos.x + i, pos.y + j) then
								local tile = map:Get(pos.x + i, pos.y + j)
								if tile.value.type == Floor then
									Engine.Glyph(pos.x + i, pos.y + j, levels[d])
								end
							end
						end
					end
				end
			end
		end
	end
end