﻿
local BumpMechanicsSystem = Engine.RegisterPlayerSystem()

function BumpMechanicsSystem:Update()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Player, Bump)):Iterator() do
			local bump = entity[Bump]
			local nx = bump.x + bump.dx
			local ny = bump.y + bump.dy
			
			local pass = Dungeon.passable:Has(nx, ny) and Dungeon.passable:Get(nx, ny).value

			if pass then
				entity:Set(MoveTo({ x = nx, y = ny }))
			elseif Dungeon.floor:Has(nx, ny) and Dungeon.floor:Get(nx, ny).value.entity ~= nil then
				Dungeon.floor:Get(nx, ny).value.entity:Set(Bumped({ by = entity.id }))
			end

			entity:Unset(Bump)
		end
	end
end