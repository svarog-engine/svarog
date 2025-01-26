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
Item = ECS.Component()

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Door = ECS.Component{ closed = true, locked = false }

Position = ECS.Component{ x = 0, y = 0 }
MoveTo = ECS.Component{ x = 0, y = 0 }

MakeDungeonRequest = ECS.Component()

Dungeon = ECS.Component{ map = {} }
DungeonEntity = World:Entity(Dungeon{ map = {} })