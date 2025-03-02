DoMeasurements = false 

IncludeGameplay "algorithms\\Stack"
IncludeGameplay "algorithms\\Bresenham"
IncludeGameplay "algorithms\\RecursiveShadowcast"

IncludeGameplay "UIRender"
IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"

LoadPlayerSystem "DefaultInputActions"
LoadPlayerSystem "InventoryInputActions"
LoadPlayerSystem "InventoryUpdate"
LoadPlayerSystem "TargetingInputActions"

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

LoadRenderSystem "DiaryRender"
LoadRenderSystem "TargetRender"
--LoadRenderSystem "UITestRender"
LoadRenderSystem "InventoryRender"

LoadScriptIfExists "debug\\DebugSpawnLibrary"
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEntitySpawnRender"

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")
