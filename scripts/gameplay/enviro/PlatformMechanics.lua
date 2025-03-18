
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

		if PlayerEntity[Hate] == nil then
			for _, e in ipairs(entities) do
				if e ~= entity then
					if e == PlayerEntity or e[Creature] ~= nil then					
						--if e == PlayerEntity then
						--	Diary.Write("You dispell the arcane gate. The tension subsides.")
						--	PlayerEntity[Tension]:Down(8)
						--elseif e[Creature] ~= nil then
						--	Diary.Write("The " .. e[Name].value .. " disturbs the magics of the portal. The tension wavers.")
						--	PlayerEntity[Tension]:Down(5)
						--end
					
						RemoveEntityFromDungeon(entity)
						World:Remove(entity)
					end
				end
			end
		else
			for _, e in ipairs(entities) do
				if e ~= entity then
					if e == PlayerEntity or e[Creature] ~= nil then
						if e == PlayerEntity then
							PlayerEntity[Tension]:Down(7)

							if PlayerEntity[Hate].chance <= 0 then
								PlayerEntity[Hate].chance = 0

								for _, en in World:Exec(ECS.Query.All(Creature)):Iterator() do
									RemoveEntityFromDungeon(en)
									World:Remove(en)
								end

								PlayerEntity:Set(Win{})
								Input.Push(Death)
							end
						elseif e[Creature] ~= nil then
							Diary.Write("The " .. e[Name].value .. " disturbs the portal. The [HATE] glyph curses!")
							PlayerEntity[Tension]:Down(1)
						end
					
						RemoveEntityFromDungeon(entity)
						World:Remove(entity)
					end
				end
			end
		end
	end
end