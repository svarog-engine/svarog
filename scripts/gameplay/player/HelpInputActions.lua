
ShowHelpWindow = false

Engine.RegisterInputSystem({ Action_Default_Help }, function()
	ShowHelpWindow = true
	Input.Push("Help")
end)

Engine.RegisterInputSystem({ Action_Help_Back }, function()
	ShowHelpWindow = false
	Input.Pop()
	UIRenderer.Clear()
end)
