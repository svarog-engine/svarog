
Diary = ECS.Component{ log = {}, index = 0 }
Expanded = ECS.Component()
DiaryEntity = World:Entity(Diary{ log = {}, index = 0 })

function Diary.Write(message)
	if message ~= nil then
		local diary = DiaryEntity[Diary]
		table.insert(diary.log, " " .. message)
		diary.index = diary.index + 1
	end
end

function Diary.Messages(n)
	local diary = DiaryEntity[Diary]
	local index = diary.index
	local messages = {}
	
	for i = n - 1, 0, -1 do
		if index - i > 0 then
			table.insert(messages, diary.log[index - i])
		else
			table.insert(messages, "")
		end
	end

	return messages
end
