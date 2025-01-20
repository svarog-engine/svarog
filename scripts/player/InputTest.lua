
table.insert(Pipeline_Player, ECS.System(
	Engine.PlayerSystem(), 
	ECS.Query.All(Action_Default_Menu), 
	function(self)
		print("MENU")
		Input.Consume(Action_Default_Menu)
	end
))
