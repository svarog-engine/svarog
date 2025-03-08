
local HateMechanicsSystem = Engine.RegisterEnviroSystem("Hate Mechanics")

function HateMechanicsSystem:ShouldTick()
	return Dungeon ~= nil and Dungeon.floor ~= nil and PlayerEntity ~= nil and PlayerEntity[Hate] ~= nil
end

function HateMechanicsSystem:Tick()
	if PlayerEntity[Hate].chance > 0 then
		if Chances[PlayerEntity[Hate].chance]:MakeGuess() then
			PlayerEntity[Hate].chance = PlayerEntity[Hate].chance - 1
			if PlayerEntity[Hate].chance < 0 then PlayerEntity[Hate].chance = 0 end

			local challengeLevel = 5
			local w, h = Dungeon.floor:Size()
			local x, y = Rand:Range(w / 4, 3 * w / 4), Rand:Range(h / 4, 3 * h / 4)

			local challengeEntity = World:Entity(MagicChallenge { time = 0, difficulty = challengeLevel })
			SpawnChallengeEntities(x, y, challengeLevel, challengeEntity.id)

			Diary.Write("[HATE] makes your other GLYPHS resonate with this chamber!")
		end
	end
end
