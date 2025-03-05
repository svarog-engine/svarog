
local HealingSystem = Engine.RegisterEnviroSystem("Healing")

function HealingSystem:ShouldTick()
	return Dungeons.created
end

function HealingSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Health, Heal)):Iterator() do
		local health = entity[Health]
		local heal = entity[Heal]

		if health.current >= health.maximum then
			return
		end

		local shouldHeal = Chances[7 + heal.level]:MakeGuess()

		if shouldHeal then
			health.current = health.current + 1
			
			if entity == PlayerEntity then
				Diary.Write("You heal for small amount!")
			end
		end

	end
end