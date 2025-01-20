
table.insert(Pipeline_Player, ECS.System(
	Engine.PlayerSystem(), 
	ECS.Query.All(Action_Default_Menu), 
	function(self)
		print("MENU")
		Input.Push("Menu")
		Input.Consume(Action_Default_Menu)
	end
))

table.insert(Pipeline_Player, ECS.System(
	Engine.PlayerSystem(), 
	ECS.Query.All(Action_Menu_Back), 
	function(self)
		print("BACK")
		Input.Pop()
		Input.Consume(Action_Menu_Back)
	end
))
