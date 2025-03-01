DoMeasurements = false 

IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"
IncludeGameplay "algorithms\\RecursiveShadowcast"

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
LoadRenderSystem "PlayerLightRender"
LoadRenderSystem "DebugDistancesRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "TargetRender"
LoadRenderSystem "LogRender"
LoadRenderSystem "InventoryRender"

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")
