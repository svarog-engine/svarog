
Engine.RegisterInputSystem(Action_Default_Menu, function() 
	print "MENU"
	Input.Push("Menu")
end)

Engine.RegisterInputSystem(Action_Menu_Back, function()
		print("BACK")
		Input.Pop()
end)
