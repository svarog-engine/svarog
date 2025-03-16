
local HateMechanicsSystem = Engine.RegisterEnviroSystem("Hate Mechanics")

function HateMechanicsSystem:ShouldTick()
	return Dungeon ~= nil and Dungeon.floor ~= nil and PlayerEntity ~= nil and PlayerEntity[Hate] ~= nil
end

function HateMechanicsSystem:Tick()
	if PlayerEntity[Hate].chance > 0 then
		PlayerEntity[Hate].chance = PlayerEntity[Hate].chance - 0.25
		if PlayerEntity[Luck] ~= nil then 
			PlayerEntity[Hate].chance = PlayerEntity[Hate].chance - 0.25
		end
		PlayerEntity[Tension]:Up(1)
	end
end
