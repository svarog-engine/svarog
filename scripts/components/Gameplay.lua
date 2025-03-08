
Player = ECS.Component()
Boons = ECS.Component{ value = {} }

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

Item = ECS.Component{id = "", quantity = 1}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Wall = ECS.Component()

Health = ECS.Component(Range(9, 9))
BumpAttack = ECS.Component { damage = 1 }

Stamina = ECS.Component(Range(9, 9))

Text = ECS.Component { text = "" }

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

function Contents.Add(entity, itemId, quantity)
	quantity = quantity or 1
	local inventory = entity[Contents].items

	local itemInInventory = false
	for _, item in ipairs(inventory) do
		if item.itemId == itemId then
			item.quantity = item.quantity + quantity
			itemInInventory = true
			break
		end
	end

	if not itemInInventory then 
		table.insert(inventory, { itemId = itemId, quantity = quantity } )
	end
end

function Contents.Remove(entity, itemId, quantity)
	quantity = quantity or 1
	local inventoryList = entity[Contents].items

	local indexToRemove = nil
	for index, i in ipairs(inventoryList) do
		if i.itemId == itemId then
			i.quantity = i.quantity - quantity
			if i.quantity <= 0 then
				indexToRemove = index
				break
			end
		end
	end

	if indexToRemove ~= nil then
		table.remove(inventoryList, indexToRemove)
	end
end

function Contents.HasItem(entity, itemId, quantity)
	quantity = quantity or 1
	local inventoryList = entity[Contents].items

	for index, item in ipairs(inventoryList) do
		if item.itemId == itemId then
			return item.quantity >= quantity
		end
	end

	return false
end

function Contents.MoveItems(source, target)
	local inventoryList = source[Contents].items
	for _, item in ipairs(inventoryList) do
		Contents.Add(target, item.itemId, item.quantity)
		Contents.Remove(source, item.itemId, item.quantity)
	end
end

function Contents.DropAll(entity, x, y)
	local inventoryList = entity[Contents].items
	for _, item in ipairs(inventoryList) do 
		local itemMeta = ItemLibrary[item.itemId]

		local itemEntity = World:Entity(
			Item{ id = item.itemId, quantity = item.quantity},
			Position{ x = x, y = y },
			Glyph{ name = itemMeta.glyph })

		AddEntityToDungeon(x, y, itemEntity)
	end

	entity[Contents].items = {}
end

function Contents.DropOne(entity, x, y)
	local inventoryList = entity[Contents].items
	local dropIndex = Rand:Range(1, #inventoryList)

	local index = 1
	for _, item in ipairs(inventoryList) do 
		if index == dropIndex then 
			local itemMeta = ItemLibrary[item.itemId]
			local itemEntity = World:Entity(
				Item{ id = item.itemId, quantity = item.quantity},
				Position{ x = x, y = y },
				Glyph{ name = itemMeta.glyph })

			AddEntityToDungeon(x, y, itemEntity)
			break
		end
		index = index + 1
	end

	entity[Contents].items = {}
end