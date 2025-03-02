
UI = ECS.Component{}

-- Statefulness 

Open = ECS.Component()
Selection = ECS.Component(1)

SelectPrev = function(entity, max)
	local selection = entity[Selection].value
	selection = selection - 1
	if selection < 1 then
		selection = max
	end

	entity[Selection].value = selection
end

SelectNext = function(entity, max)
	local selection = entity[Selection].value
	selection = selection + 1
	if selection > max then
		selection = 1
	end

	entity[Selection].value = selection
end

-- Targeting 

ActivateTargetOverlay = ECS.Component{ callback = nil }
DeactivateTargetOverlay = ECS.Component{ success = false }

TargetOverlayEntity = World:Entity(Position{ x = 0, y = 0 })

-- Inventory

ActivateInventoryOverlay = ECS.Component()
DeactivateInventoryOverlay = ECS.Component()
Contents = ECS.Component{ items = {} }
DoInventoryAction = ECS.Component{ action = nil, details = {} }

InventoryEntity = World:Entity(Selection(0))