
local BumpAltarMechanicsSystem = Engine.RegisterEnviroSystem("Bump Altar")

function BumpAltarMechanicsSystem:ShouldTick()
	return Dungeon ~= nil and PlayerEntity ~= nil
end

local TakenBoon = {}

TakenBoon["Endure"] = "You gained the [ENDURE] glyph. You feel it pulsing."
TakenBoon["Break"] = "You found the [BREAK] glyph. You feel it crackling."
TakenBoon["Luck"] = "You stumbled onto the [LUCK] glyph. It must have been fate."
TakenBoon["Darken"] = "You enveloped the [DARKEN] glyph. It feels endless."
TakenBoon["Flow"] = "You touched the [FLOW] glyph. You feel it reconfigure."
TakenBoon["Heal"] = "You embraced the [HEAL] glyph. It replaces your heart."
TakenBoon["Calm"] = "You've taken the [CALM] glyph. It mellows within." 
TakenBoon["Open"] = "You feel the [OPEN] glyph behind your eyes. It expands."
TakenBoon["Light"] = "The [LIGHT] glyph makes your eyes leave trails in the air."

function BumpAltarMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Altar, Satiated)):Iterator() do
		local t = CompNameToComp(entity[Altar].type)
		PlayerEntity:Set(t())
		table.insert(PlayerEntity[Boons].value, entity[Altar].type)
		Diary.Write(TakenBoon[entity[Altar].type])
		entity:Unset(Bumped)
		MakeDungeon()
	end
end
