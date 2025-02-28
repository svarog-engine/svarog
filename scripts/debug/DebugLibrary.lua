-- UI

DebugSpawnerWidget = ECS.Component {top = 1, left = 1, width = 20, height = 40, selected = 1, size = 0}

DebugUI = World:Entity(
	DebugSpawnerWidget {top = 1, left = 39, width = 20, height = 40, selected = 1, size = 0}
)