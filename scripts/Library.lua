-- Define your components here

Diary = ECS.Component{ log = {}, index = 0 }
DiaryEntity = World:Entity(Diary{ log = {}, index = 0 })

function Diary.Write(message)
	local diary = DiaryEntity[Diary]
	table.insert(diary.log, message)
	diary.index = diary.index + 1
end

Glyph = ECS.Component{ char = " ", fg = nil, bg = nil }

FadeOut = ECS.Component{ start = nil, target = nil, time = 0, speed = 0.1 }

function Fade(entity, start, target, speed)
	if speed == nil then speed = 0.1 end
	entity:Set(FadeOut{ start = start, target = target, time = 0, speed = speed })
end

Player = ECS.Component()
Creature = ECS.Component()
Friendly = ECS.Component()
Item = ECS.Component{id = ""}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Door = ECS.Component{ closed = true, locked = false }

Position = ECS.Component{ x = 0, y = 0 }
MoveTo = ECS.Component{ x = 0, y = 0 }

MakeDungeonRequest = ECS.Component()
Dungeon = {}

ApproachBehaviour = ECS.Component()
HoldDistanceBehaviour = ECS.Component{ distance = 5 }

Inventory = ECS.Component{items = {}}

function Inventory.Add(entity, item)
	local inventory = entity[Inventory]
	table.insert(inventory.items, item)
end

-- UI

InventoryWidget = ECS.Component{top = 1, left = 39, width = 20, height = 20, selected = 1, source = {}}
ItemDetailsPanelWidget = ECS.Component {top = 0, left = 20, width = 15, height = 20}

function InventoryWidget.GetSelected()
	local widget = UI[InventoryWidget]
	if widget.selected <= #(widget.source.items) then
		for i, s in ipairs(widget.source.items) do
			if i == widget.selected then
				return s
			end
		end
	end

	return nil
end

UI = World:Entity(
	InventoryWidget{ top = 1, left = 39, width = 20, height = 10, source = {}, selected = 1},
	ItemDetailsPanelWidget{top = 1, left = 20, width = 15, height = 1}
)