DoMeasurements = false 

IncludeGameplay "algorithms\\Stack"
IncludeGameplay "algorithms\\Bresenham"
IncludeGameplay "algorithms\\RecursiveShadowcast"

IncludeGameplay "UIRender"
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

--LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
--LoadRenderSystem "TopLevelRender"
--LoadRenderSystem "LogRender"
LoadRenderSystem "TargetRender"
LoadRenderSystem "UITestRender"
--LoadRenderSystem "InventoryRender"

LoadScriptIfExists "debug\\DebugSpawnLibrary"
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEnitySpawnRender"

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")
