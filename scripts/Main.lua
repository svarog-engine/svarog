DoMeasurements = false 

IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"
IncludeGameplay "algorithms\\RecursiveShadowcast"
LoadScriptIfExists "debug\\DebugSpawnLibrary"

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
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEnitySpawnRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "TargetRender"
LoadRenderSystem "LogRender"
LoadRenderSystem "InventoryRender"

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")
