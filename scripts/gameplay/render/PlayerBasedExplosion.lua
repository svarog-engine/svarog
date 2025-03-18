
local PlayerBasedExplosionSystem = Engine.RegisterRenderSystem("Player Explosion Render")

function PlayerBasedExplosionSystem:ShouldRender()
	return Dungeon ~= nil and Dungeon.playerDistance ~= nil
end

function PlayerBasedExplosionSystem:Render()
	for _, entity in World:Exec(ECS.Query.All(Player, Position, VFXExplosion)):Iterator() do
		local x, y = entity[Position].x, entity[Position].y
		local w, h = Dungeon.playerDistance:Size()
		local vfx = entity[VFXExplosion]
		local bg = vfx.bg or Colors.Magenta
		local fg = vfx.fg or Colors.White
		local callback = vfx.callback or function() end
		if vfx.current > vfx.maximum then
			entity:Unset(VFXExplosion)
		else
			local px = math.max(1, x - vfx.maximum)
			local qx = math.min(w, x + vfx.maximum)			
			local py = math.max(1, y - vfx.maximum)
			local qy = math.min(h, y + vfx.maximum)

			for i = px, qx do
				for j = py, qy do
					local d = Dungeon.playerDistance:Get(i, j)
					if d < vfx.current then
						local v = 1 - vfx.current / vfx.maximum
						local eased = v * v * v
						Engine.Fg(i, j, LerpColor(fg, Colors.LightGray, eased + (Rand:F01() - 0.5) * 0.5 ))
						Engine.Bg(i, j, LerpColor(bg, Colors.Black, eased + (Rand:F01() - 0.5) * 0.5 ))
					elseif d == vfx.current then
						Engine.Fg(i, j, Colors.White)
						Engine.Bg(i, j, Colors.White)
					end
				end
			end
			vfx.current = vfx.current + 1
			if vfx.current == vfx.maximum - 1 then
				callback()
			end
		end
	end
end

