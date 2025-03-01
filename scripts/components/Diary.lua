
Diary = ECS.Component{ log = {}, index = 0 }
DiaryEntity = World:Entity(Diary{ log = {}, index = 0 })

function Diary.Write(message)
	local diary = DiaryEntity[Diary]
	table.insert(diary.log, message)
	diary.index = diary.index + 1
end
