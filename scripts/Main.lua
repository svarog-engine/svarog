
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

LoadEnviroSystem "FriendlySwapBehaviour"
LoadEnviroSystem "PassabilityUpdate"
LoadEnviroSystem "FireSpreadingMechanics"
LoadEnviroSystem "AIBehaviours"
LoadEnviroSystem "TurnOrder"
LoadEnviroSystem "UpdateDistances"
LoadEnviroSystem "HealingMechanics"
LoadEnviroSystem "BumpAttackMechanics"
LoadEnviroSystem "DelayedDamageMechanics"
LoadEnviroSystem "StatusEffectUpdate"
LoadEnviroSystem "InflictStatusMechanics"
LoadEnviroSystem "PickUpMechanics"
LoadEnviroSystem "ShadowCastMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "PossibleMoveRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "VFXRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "DiaryRender"
LoadRenderSystem "PlayerInfoRender"
LoadRenderSystem "TargetRender"
LoadRenderSystem "InventoryRender"

LoadScriptIfExists "debug\\DebugSpawnLibrary"
LoadScriptIfExists "debug\\render\\DebugDistancesRender"
LoadScriptIfExists "debug\\render\\DebugEntitySpawnRender"

World:Entity(MakeDungeonRequest)
Diary.Write("7DRL PANIC")