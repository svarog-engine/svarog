
-- DEFAULT

Engine.RegisterInputSystem(Action_Default_Debug, function() Input.Push("Debug") end)

Engine.RegisterInputSystem(Action_Default_Left, function()
	for i = 0, Options.WorldWidth - 1 do
		for j = 0, Options.WorldHeight - 1 do
			Engine.Draw({ X = i, Y = j, Presentation = Rand:Char(), Foreground = Rand:Color(), Background = Rand:Color() })
		end
	end
end)

-- DEBUG

Engine.RegisterInputSystem(Action_Debug_Back, function() Input.Pop() end)
Engine.RegisterInputSystem(Action_Debug_Reload, function() Svarog.Instance:Reload() end)