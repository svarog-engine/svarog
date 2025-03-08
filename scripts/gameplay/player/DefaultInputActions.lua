-- DEFAULT

LoadScriptIfExists "debug\\DebugInputActions"

Engine.RegisterInputSystem({ Action_Default_Wait }, function(input)
	World:Exec(ECS.Query.All(Player, Stamina, Tension, Pause)):ForEach(function(entity)
		local stam = entity[Stamina]
		local pause = entity[Pause]
		local tension = entity[Tension]
		local plus = 1

		pause.duration = pause.duration + 1
		if pause.duration > 6 then pause.duration = 6 end

		if pause.duration == 4 then
			tension.current = tension.current - 1
			if tension.current < 0 then
				tension.current = 0
			end
		end

		if stam.current < stam.maximum then
			stam.current = stam.current + plus
			if stam.current > stam.maximum then 
				stam.current = stam.maximum
			end
		end
		PlayerDone = true
	end)
end)

Engine.RegisterInputSystem({ Action_Default_JumpOn }, function(input)
	World:Exec(ECS.Query.All(Player, MoveMode, Position)):ForEach(function(entity)
		entity[MoveMode].value = "Jump"
	end)
end)

Engine.RegisterInputSystem({ Action_Default_JumpOff }, function(input)
	World:Exec(ECS.Query.All(Player, MoveMode, Position)):ForEach(function(entity)
		entity[MoveMode].value = "Walk"
	end)
end)

Engine.RegisterInputSystem({ Action_Default_Tension }, function(input)
	World:Exec(ECS.Query.All(Player, Tension)):ForEach(function(entity)
		entity[Tension]:Up(2)
		MakeDungeon()
	end)
end)

Engine.RegisterInputSystem(
	{
		Action_Default_Left, 
		Action_Default_Right, 
		Action_Default_Up, 
		Action_Default_Down
	}, function(input)

	World:Exec(ECS.Query.All(Player, MoveMode, Stamina, Position, Pause)):ForEach(function(entity)
		local move = entity[MoveMode]
		local stam = entity[Stamina]
		local pause = entity[Pause]
		pause.duration = 0
		local speed = 1
		if move.value == "Jump" then speed = 2 end
		local dxl = (input[Action_Default_Left] and -1 or 0) 
		local dxr = (input[Action_Default_Right] and 1 or 0)
		local dyl = (input[Action_Default_Up] and -1 or 0)
		local dyr = (input[Action_Default_Down] and 1 or 0)
		local dx = dxl + dxr
		local dy = dyl + dyr
		local pos = entity[Position]
		
		local cost = speed - 1
		local mult = 1

		if entity[Endure] ~= nil then mult = 0.5 end
		if entity[Endure] ~= nil and speed == 1 and stam.current < stam.maximum and Chances[1 + entity[Endure].level]:MakeGuess() then
			stam.current = stam.current + 1
			PlayerEntity[Tension]:Up()
			Diary.Write("You regain stamina. Your [ENDURE] glyph quivers.")
		end

		local moved = 0

		if entity[Flow] ~= nil then
			if speed == 2 then
				local x, y = pos.x + dx, pos.y + dy	
				local id = Dungeon.floor:ID(x, y)
				local entts = Dungeon.entities[id] or {}
				if Dungeon.passable:Has(x, y) and not Dungeon.passable:Get(x, y) then
					cost = 4
					if stam.current >= cost * mult and PerformBump(entity, pos.x, pos.y, dx * speed, dy * speed) then
						PlayerEntity[Tension]:Up()
						Diary.Write("You phase through solid matter! Your [FLOW] glyph quivers.")
						moved = moved + 1
						entity[Stamina].current = entity[Stamina].current - cost * mult
					end
				elseif Dungeon.passable:Has(x, y) and #entts > 0 then
					local name = Dungeon.entities[id][1][Name].value
					cost = 3
					if stam.current >= cost * mult and PerformBump(entity, pos.x, pos.y, dx * speed, dy * speed) then
						PlayerEntity[Tension]:Up()
						Diary.Write("You phase through the " .. name .. "! Your [FLOW] glyph quivers.")
						entity[Stamina].current = entity[Stamina].current - cost * mult
					end
				elseif Dungeon.passable:Has(x + dx, y + dy) and Dungeon.passable:Has(x + dx, y + dy) then
					cost = 2
					if stam.current >= cost * mult and PerformBump(entity, pos.x, pos.y, dx * speed, dy * speed) then
						entity[Stamina].current = entity[Stamina].current - cost * mult
					end
				end
			else
				if stam.current >= cost * mult and PerformBump(entity, pos.x, pos.y, dx, dy) then 
					moved = moved + 1
					entity[Stamina].current = entity[Stamina].current - cost * mult
				end
			end
		else
			for i = 1, speed do
				if stam.current >= cost * mult and PerformBump(entity, pos.x, pos.y, dx, dy) then 
					moved = moved + 1
					entity[Stamina].current = entity[Stamina].current - cost * mult
				end
			end
		end

		if moved > 0 then
			PlayerDone = true
		end
	end)
end)

Engine.RegisterInputSystem({ Action_Default_ZoomIn }, function()
	local currentSize = Config.FontSize
	local maxSize = Config.FontMaxSize
	local step = Config.FontChangeStep

	if currentSize < maxSize then
		if currentSize + step > maxSize then
			Config.FontSize = maxSize
		else
			Config.FontSize = currentSize + step
		end

		Svarog.Instance:ReloadPresenter()
	end
end)

Engine.RegisterInputSystem({ Action_Default_ZoomOut }, function() 
	local currentSize = Config.FontSize
	local minSize = Config.FontMinSize
	local step = Config.FontChangeStep

	if currentSize > minSize then
		if currentSize - step < minSize then
			Config.FontSize = minSize
		else
			Config.FontSize = currentSize - step
		end

		Svarog.Instance:ReloadPresenter()
	end
end)

Engine.RegisterInputSystem({ Action_Default_Reload }, function() Svarog.Instance:Reload() end)
