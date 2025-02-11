DoMeasurements = false 

IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"
IncludeGameplay "algorithms//RecursiveShadowcast"

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

PlayerEntity = World:Entity(
    Player(), 
    Position{ x = math.floor(Config.Width / 2), y = math.floor(Config.Height / 2) },
    Glyph{ name = "mage" },
    Inventory{ items = {}}
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")
