
Input = {}
InputEntity = World:Entity()

Input.Press = function(input)
	return { action = "press", input = input, length = 0 }
end

Input.Hold = function(input, time)
	return { action = "hold", input = input, length = time }
end

Input.Release = function(input)
	return { action = "release", input = input, length = 0.0 }
end

Input.Push = function(ctx)
	InputStack:Push(ctx)
end

Input.Pop = function()
	InputStack:Pop()
end

Input.Consume = function(input)
	InputEntity:Unset(input)
end

Input.Update = function()
	if ActionTriggers.Count > 0 then
		for i = 0, ActionTriggers.Count - 1 do
			local action = "Action_" .. (InputStack:Peek()) .. "_" .. (ActionTriggers[i])
			if _G[action] ~= nil then
				InputEntity:Set(_G[action]())
			else
				Svarog:LogError("Action " .. ActionTriggers[i] .. " not found in context " .. (InputStack:Peek()))
			end
		end
	end
end

return Input