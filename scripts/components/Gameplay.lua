
Player = ECS.Component()
MoveMode = ECS.Component{value = ""}
Sight = ECS.Component{ radius = 5 }
Pause = ECS.Component{ duration = 0 }
Friendly = ECS.Component()
Creature = ECS.Component{ goals = {}, actions = 0, timestamp = 0 }

function TickCreature(entity)
	if Engine.Tick() > entity[Creature].timestamp then
		entity[Creature].timestamp = entity[Creature].timestamp + 1
		entity[Creature].goals = {}
	end
end

Item = ECS.Component{id = ""}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Wall = ECS.Component()

Health = ECS.Component(Range(9, 9))
BumpAttack = ECS.Component { damage = 1 }

Stamina = ECS.Component(Range(9, 9))

-- Challenge

Challenged = ECS.Component()
Dependent = ECS.Component{value = nil}
MagicChallenge = ECS.Component { time = 0, difficulty = 0 }
Magic = ECS.Component{value = 0.0}
Timeout = ECS.Component{value = 0.0}
Portal = ECS.Component { challenge = nil }
VFXExplosion = ECS.Component(Range(0, 10))

-- Tension

Tension = ECS.Component(Range(9, 9))

function Tension:Up(n)
	if self.current < self.maximum then
		self.current = self.current + (n or 1)

		if self.current >= self.maximum then
			self.current = self.maximum
			PlayerEntity:Set(Challenged())
		end
	end
end

function Tension:Down(n)
	self.current = self.current - (n or 1)
end

-- Inventory

Contents = ECS.Component{ items = {} }

function Contents.Add(entity, item)
	local inventory = entity[Contents]
	table.insert(inventory.items, item)
end

function Contents.Remove(entity, item)
	local inventoryList = entity[Contents].items
	table.remove(inventoryList, table.find(inventoryList, item))
end

function Contents.HasItem(entity, item)
	local inventoryList = entity[Contents].items
	if inventoryList ~= nil then
		for _, value in ipairs(inventoryList) do 
			if value == item then
				return true
			end
		end
	end

	return false
end

function Contents.MoveItems(source, target)
	local inventoryList = source[Contents].items
	for _, item in pairs(inventoryList) do 
		Contents.Add(target, item)
		Contents.Remove(source, item)
	end
end

function Contents.DropAll(entity, x, y)
	local inventoryList = entity[Contents].items
	for _, item in ipairs(inventoryList) do 
		local itemMeta = ItemLibrary[item]

		local itemEntity = World:Entity(
			Item{ id = item },
			Position{ x = x, y = y },
			Glyph{ name = itemMeta.glyph })

		AddEntityToDungeon(x, y, itemEntity)
	end

	entity[Contents].items = {}
end