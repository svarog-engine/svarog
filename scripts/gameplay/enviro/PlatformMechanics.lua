
local PlatformSystem = Engine.RegisterEnviroSystem("Platforms")

function PlatformSystem:ShouldTick()
	return Dungeons.created
end

function PlatformSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Portal, Position)):Iterator() do
		local position = entity[Position]
		local portal = entity[Portal]

		local id = Dungeon.floor:ID(position.x, position.y)
		local entities = Dungeon.entities[id] or {}

		for _, e in ipairs(entities) do
			if e ~= entity then
				if e == PlayerEntity or e[Creature] ~= nil or e[Item] ~= nil then					
					if e == PlayerEntity then
						Diary.Write("You dispell the arcane gate. Tension subsides.")
					elseif e[Creature] ~= nil then
						Diary.Write("The " .. e[Name].value .. " disturbs the magics of the portal. Tension subsides.")
					else
						Diary.Write("The " .. e[Name].value .. " splits the eldritch doorway. Tension subsides.")
					end
					PlayerEntity[Tension]:Down(3)
					RemoveEntityFromDungeon(entity)
					World:Remove(entity)
				end
			end
		end
	end
end