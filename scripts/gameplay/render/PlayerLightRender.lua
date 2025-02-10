local PlayerLightRenderSystem = Engine.RegisterRenderSystem()

function PlayerLightRenderSystem:Render()
	if Dungeons.created and not DebugToggle_FOV then
		for _, e in World:Exec(ECS.Query.All(Player, Position)):Iterator() do
			local pos = e[Position]
			local levels = { "back_semi", "back_mid", "back_lit" }
			for i = -3, 3 do
				for j = -3, 3 do
					if not (i == 0 and j == 0) then 
						local x = pos.x + i
						local y = pos.y + j
						if Dungeons.playerDistance:Has(x, y) then
							local d = math.floor(Dungeons.playerDistance:Get(x, y))
							if d < 4 and d > 0 then
								d = 4 - d
								if Dungeon.floor:Has(x, y) then
									local tile = Dungeon.floor:Get(x, y)
									if tile.type == Floor then
										Engine.Glyph(x, y, levels[d])
									end
								end
							end
						end
					end
				end
			end
		end
	end
end