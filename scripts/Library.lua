﻿-- Define your components here

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
Item = ECS.Component{name = ""}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Door = ECS.Component{ closed = true, locked = false }

Position = ECS.Component{ x = 0, y = 0 }
MoveTo = ECS.Component{ x = 0, y = 0 }

MakeDungeonRequest = ECS.Component()
Dungeon = {}

FollowBehaviour = ECS.Component{ distance = 5 }
ApproachBehaviour = ECS.Component()

Inventory = ECS.Component{items = {}}

function Inventory.Add(entity, item)
	local inventory = entity[Inventory]
	table.insert(inventory.items, item)
end

-- find new home for this lonely fella
Widgets = {
	Inventory = {top = 1, left = 39, width = 20, height = 20}
}