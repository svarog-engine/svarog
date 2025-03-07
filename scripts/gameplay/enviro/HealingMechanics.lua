
local HealingSystem = Engine.RegisterEnviroSystem("Healing")

function HealingSystem:ShouldTick()
	return Dungeons.created
end

function Clamp(a, b)
	if a > b then
		return b
	else
		return a
	end
end

function HealingSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Health, Heal)):Iterator() do
		local health = entity[Health]
		local heal = entity[Heal]

		if health.current >= health.maximum then
			return
		end

		local shouldHeal = Chances[heal.chance + heal.level]:MakeGuess()

		if shouldHeal then
			local healingAmount = 1

			local gotLucky = false
			local luck = entity[Luck]
			if luck ~= nil then
				if Chances[luck.chance]:MakeGuess() then
					healingAmount = healingAmount * luck.multiplier
					gotLucky = true
				end
			end

			health.current = Clamp(health.current + healingAmount, health.maximum)
			if entity[Tension] ~= nil then 
				entity[Tension]:Up(healingAmount)
			end

			if entity == PlayerEntity then
				if gotLucky then
					Diary.Write("Your wounds heal quickly. Your [HEAL] and [LUCK] glyphs resonate.")
				else
					Diary.Write("Your wounds heal. Your [HEAL] glyph quivers.")
				end
			end
		end

	end
end