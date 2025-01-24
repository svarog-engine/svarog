
local BumpMechanicsSystem = Engine.RegisterPlayerSystem()

function BumpMechanicsSystem:Update()
	local map = DungeonEntity[Dungeon].map
	if map ~= nil then
		for _, entity in World:Exec(ECS.Query.All(Player, Bump)):Iterator() do
			local bump = entity[Bump]
			local nx = bump.x + bump.dx
			local ny = bump.y + bump.dy
			
			local pass = map:Has(nx, ny) and map:Get(nx, ny).value.pass
			if pass then
				entity:Set(MoveTo({ x = nx, y = ny }))
			elseif map:Has(nx, ny) and map:Get(nx, ny).entity ~= nil then
				map:Get(nx, ny).entity:Set(Bumped({ by = entity }))
			end

			entity:Unset(Bump)
		end
	end
end