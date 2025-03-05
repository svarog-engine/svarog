DoMeasurements = false 

IncludeGameplay "DungeonEntities"
IncludeGameplay "Chances"
IncludeGameplay "UIRender"
IncludeGameplay "Wheels"
IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"

LoadPlayerSystem "DefaultInputActions"
LoadPlayerSystem "InventoryInputActions"
LoadPlayerSystem "InventoryUpdate"
LoadPlayerSystem "TargetingInputActions"

--LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FriendlySwapBehaviour"
LoadEnviroSystem "PassabilityUpdate"
LoadEnviroSystem "AIBehaviours"
LoadEnviroSystem "TurnOrder"
LoadEnviroSystem "UpdateDistances"
LoadEnviroSystem "ShadowCastMechanics"
LoadEnviroSystem "HealingMechanics"
LoadEnviroSystem "BumpAttackMechanics"
LoadEnviroSystem "DelayedDamageMechanics"
LoadEnviroSystem "StatusEffectUpdate"
LoadEnviroSystem "InflictStatusMechanics"
LoadEnviroSystem "PickUpMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "DiaryRender"
LoadRenderSystem "PlayerInfoRender"
LoadRenderSystem "TargetRender"
LoadRenderSystem "InventoryRender"
--LoadRenderSystem "UITestRender"

LoadScriptIfExists "debug\\DebugSpawnLibrary"
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEntitySpawnRender"

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")