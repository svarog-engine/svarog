
Input = {}

Input.Press = function(input)
	return { action = "press", input = input, length = 0 }
end

Input.Hold = function(input, time)
	return { action = "hold", input = input, length = time }
end

Input.Release = function(input)
	return { action = "release", input = input, length = 0.0 }
end

Input.MouseMove = function(input)
	return { action = "mousemove", input = input, length = 0.0 }
end

Input.Push = function(ctx)
	Svarog:LogInfo("Pushed input context: " .. ctx)
	InputStack:Push(ctx)
end

Input.Clear = function()
	Svarog:LogInfo("Input contexts cleared")
	InputStack:PopAll()
end

Input.Pop = function()
	Svarog:LogInfo("Popped input context")
	InputStack:Pop()
end

Input.Peek = function()
	return InputStack:Peek()
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

Input.HoldRatio = function(input)
	local maxHold = 0
	local currentHold = 0
	local context = Actions[InputStack:Peek()]
	if context ~= nil then
		local action = context[input]
		if action ~= nil then
			for _, definition in ipairs(action) do
				if definition.input ~= nil then
					maxHold = definition.length or 0
					currentHold = InputStack:GetHoldRatio(definition.input)
					break
				end
			end
		end
	end

	return maxHold, currentHold
end

return Input