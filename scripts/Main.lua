DoMeasurements = false 

IncludeGameplay "algorithms\\Stack"
IncludeGameplay "algorithms\\Bresenham"
IncludeGameplay "algorithms\\RecursiveShadowcast"

IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"

LoadPlayerSystem "InputActions"

LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FriendlySwapBehaviour"
LoadEnviroSystem "PickUpMechanics"
LoadEnviroSystem "PassabilityUpdate"
LoadEnviroSystem "AIBehaviours"
LoadEnviroSystem "TurnOrder"
LoadEnviroSystem "UpdateDistances"
LoadEnviroSystem "ShadowCastMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "UIRender"
--LoadRenderSystem "LogRender"
--LoadRenderSystem "TargetRender"
--LoadRenderSystem "InventoryRender"

LoadScriptIfExists "debug\\DebugSpawnLibrary"
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEnitySpawnRender"

World:Entity(UI{work = function(ui)
	ui.PushBox(10, 10, 40, 40)
		ui.PushOrder("-")
			ui.Label("Hello")
			ui.Space(5)
			ui.Label("world")
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(40, 10, 40, 40)
		ui.PushOrder("|")
			ui.Label("Hello")
			ui.Space(5)
			ui.Label("world")
		ui.PopOrder()
	ui.PopBox()

	ui.Line(5, 5, 25, 33)
	ui.Rect(15, 15, 20, 20)
end})

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")
