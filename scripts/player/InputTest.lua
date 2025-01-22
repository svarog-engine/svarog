
-- DEFAULT
Engine.RegisterInputSystem(Action_Default_Debug, function() 
	Input.Push("Debug") 
end)

Engine.RegisterInputSystem(Action_Default_Left, function()
	local cx, cy = Config.WorldWidth / 2, Config.WorldHeight / 2
	for i = 0, Config.WorldWidth - 1 do
		for j = 0, Config.WorldHeight - 1 do
			if (i - cx) * (i - cx) + (j - cy) * (j - cy) < 10 * 10 then
				Engine.Draw({ X = i, Y = j, Presentation = ".", Foreground = Colors.Green, Background = Colors.Black })
			else
				Engine.Draw({ X = i, Y = j, Presentation = " ", Foreground = Colors.Green, Background = Colors.Black })
			end
		end
	end
end)

-- DEBUG

Engine.RegisterInputSystem(Action_Debug_Back, function() Input.Pop() end)
Engine.RegisterInputSystem(Action_Debug_Reload, function() Svarog.Instance:Reload() end)