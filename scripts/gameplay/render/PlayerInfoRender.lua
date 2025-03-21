
local PlayerInfoRenderSystem = Engine.RegisterUIRenderSystem("Player Info Render");

local Components = { 
	Health = Health, 
	Tension = Tension,
	Stamina = Stamina,
	Telepathic = Telepathic, 
	Invisible = Invisible,
	Delayed = Delayed,
	Blindness = Blindness,
	Paralyzed = Paralyzed,
	Silenced = Silenced,
}

local ComponentsInOrder = {
	"Health", "Stamina", "Tension",
	"Silenced", "Telepathic", "Invisible", "Delayed", "Blind", "Paralyzed",
}

local ComponentColors = {
	Health = Colors.Red,
	Tension = Colors.LightMagenta,
	Stamina = Colors.Green
}

function PlayerInfoRenderSystem:ShouldRender(ui)
	return PlayerEntity ~= nil and PlayerEntity[Boons] ~= nil
end

function PlayerInfoRenderSystem.Render(ui)
	local player = PlayerEntity
	if player == nil then
		return
	end

	local times = {}
	for _, e in World:Exec(ECS.Query.All(TempBoon, Timeout)):Iterator() do
		local type = e[TempBoon].type
		if times[type] == nil then
			times[type] = e[Timeout].value
		else
			times[type] = times[type] + e[Timeout].value
		end
	end

	UIRenderer.ClearBox(47, 2, 20, 20)

	if Level ~= nil and not FIN then
		ui.PushBox(2, 2, 20, 2)
			ui.Label("LEVEL: " .. tostring(Level) .. "/6")
		ui.PopBox()
	end

	ui.PushBox(47, 2, 20, 20)
		ui.PushOrder("|")
			ui.PushStyle(Colors.Yellow, Colors.Black)

			if Seals > 0 then
				ui.PushStyle(Colors.White, Colors.Black)
				ui.Label("[ROYAL SEAL]")
				ui.PopStyle()
			end

			for _, name in ipairs(PlayerEntity[Boons].value) do
				ui.PushStyle(CompColors[name][1], Colors.Black)
				
				local label = "[" .. name .. "]"
					
				if times[name] ~= nil then
					label = label .. " (" .. times[name] .. ")"
				end

				ui.Label(label)
				ui.PopStyle()
			end

			ui.PopStyle()
			
			ui.Space(1)

			for _, name in ipairs(ComponentsInOrder) do
				local comp = Components[name]
				local v = player[comp]
				if v ~= nil then
					if ComponentColors[name] ~= nil then
						ui.PushStyle(ComponentColors[name], Colors.Black)
					end
					ui.Bar(name, v.current, v.maximum, { width = v.maximum })
					if ComponentColors[name] ~= nil then
						ui.PopStyle()
					end
				end
			end

			if PlayerEntity[Hate] ~= nil then
				local colorFill = { Colors.Magenta, Colors.Red, Colors.Yellow, Colors.Cyan }
				ui.PushStyle(colorFill[Rand:Range(1, #colorFill)], Colors.Black)
					ui.Bar("SPITEFUL", PlayerEntity[Hate].chance, 100, { width = 9 })
				ui.PopStyle()
					ui.Space(1)
				ui.PushStyle(colorFill[Rand:Range(1, #colorFill)], Colors.Black)
					ui.Label(" SURVIVE ")
				ui.PopStyle()
				ui.PushStyle(colorFill[Rand:Range(1, #colorFill)], Colors.Black)
					ui.Label(" THROUGH ")
				ui.PopStyle()
				ui.PushStyle(colorFill[Rand:Range(1, #colorFill)], Colors.Black)
					ui.Label("  SPITE ")
				ui.PopStyle()
			end


		ui.PopOrder()
	ui.PopBox()
end
