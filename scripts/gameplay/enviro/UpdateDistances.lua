
local UpdateDistancesSystem = Engine.RegisterEnviroSystem("Update Distances")

function UpdateDistancesSystem:ShouldTick()
	return Dungeons.created and Dungeon ~= nil and Dungeon.playerDistance ~= nil and PlayerEntity ~= nil
end

function UpdateDistancesSystem:Tick()
	Dungeon.playerDistance.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
	Dungeon.playerDistance:Flood()

	Dungeon.playerDistanceEmpty.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
	Dungeon.playerDistanceEmpty:Flood()

	local creatures = {}
	for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
		table.insert(creatures, { entity[Position].x, entity[Position].y })
	end
	
	Dungeon.creatureDistance.goals = creatures
	Dungeon.creatureDistance:Flood()

	local items = {}
	for _, entity in World:Exec(ECS.Query.All(Item, Position)):Iterator() do
		table.insert(items, { entity[Position].x, entity[Position].y })
	end

	Dungeon.itemDistance.goals = items
	Dungeon.itemDistance:Flood()

	Dungeon.toEverything = CompositeDistanceMap:From({ Dungeon.playerDistance, Dungeon.creatureDistance, Dungeon.itemDistance })
	Dungeon.toCreaturesAndItems = CompositeDistanceMap:From({ Dungeon.creatureDistance, Dungeon.itemDistance })
	Dungeon.toPlayerAndCreatures = CompositeDistanceMap:From({ Dungeon.playerDistance, Dungeon.creatureDistance })
	Dungeon.toPlayerAndItems = CompositeDistanceMap:From({ Dungeon.playerDistance, Dungeon.itemDistance })
end