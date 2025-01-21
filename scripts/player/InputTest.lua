
Engine.RegisterInputSystem(Action_Default_Menu, function() 
	print "MENU"
	Input.Push("Menu")
end)

Engine.RegisterInputSystem(Action_Default_Left, function()
	for i = 0, Options.WorldWidth - 1 do
		for j = 0, Options.WorldHeight - 1 do
			Engine.Draw({ X = i, Y = j, Presentation = Rand:Char(), Foreground = Rand:Color(), Background = Rand:Color() })
		end
	end
end)

Engine.RegisterInputSystem(Action_Menu_Back, function()
		print("BACK")
		Input.Pop()
end)