
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
--TakenBoon["Calm"] = "You've taken the [CALM] glyph. It mellows within." 
TakenBoon["Open"] = "You feel the [OPEN] glyph behind your eyes. It expands."
TakenBoon["Light"] = "The [LIGHT] glyph makes your eyes leave trails in the air."
TakenBoon["Hate"] = "The enemy. The [HATE] glyph desires a stronger host."

Seals = 0

function BumpAltarMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Altar)):Iterator() do
		if entity[Satiated] ~= nil then
			if World:FetchEntityById(entity[Bumped].by) == PlayerEntity then
				if PlayerEntity[Silenced] ~= nil then
					Diary.Write("Your silenced mind can't touch the glyph. " .. tostring(PlayerEntity[Silenced].current) .. " more turns.")
					Fade(PlayerEntity, Colors.Red, Colors.Black, 0.25)
				else
					local t = CompNameToComp(entity[Altar].type)
					local hasT = PlayerEntity[t] ~= nil 
				
					BoonWindow.seal = hasT
					BoonWindow.type = entity[Altar].type
					BoonWindow.onDone = function(bw)
						if bw.seal then
							Seals = Seals + 1
							Diary.Write("You take hold of a goblin queen's ROYAL SEAL.")
							Diary.Write("Go forth and seal the hate...")
							entity:Unset(Bumped)
							MakeDungeon()
						else
							local t = CompNameToComp(bw.type)
							PlayerEntity:Set(t())
							table.insert(PlayerEntity[Boons].value, bw.type)
							Diary.Write(TakenBoon[bw.type])
							entity:Unset(Bumped)
							MakeDungeon()
						end
					end
					BoonWindow.open = true
					Input.Push("Boon")
				end
			end
		else
			if World:FetchEntityById(entity[Bumped].by) == PlayerEntity then
				Fade(entity, Colors.Red, Colors.Black, 0.5)
				Diary.Write("The cold stone of the altar seems inert.")
				Diary.Write("A release of tension near it should stir it to life!")
			end
		end
	end
end
