
Engine.RegisterInputSystem({ Action_Boon_Take }, function()
	BoonWindow.onDone(BoonWindow)
	Input.Pop()
	BoonWindow.open = false
	UIRenderer.Clear()
end)

Engine.RegisterInputSystem({ Action_Boon_Back }, function()
	Input.Pop()
	BoonWindow.open = false
	UIRenderer.Clear()
end)
