
local PlayerInfoRenderSystem = Engine.RegisterUIRenderSystem("Player Info Render");

local Components = { 
	Health = Health, 
	Tension = Tension,
	Stamina = Stamina,
	Telepathic = Telepathic, 
	Invisible = Invisible,
	Delayed = Delayed,
	Blindness = Blindness,
}

local ComponentsInOrder = {
	"Health", "Stamina", "Tension",
	"Telepathic", "Invisible", "Delayed", "Blindness"
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

	UIRenderer.ClearBox(47, 2, 20, 20)

	ui.PushBox(47, 2, 20, 20)
		ui.PushOrder("|")
			ui.PushStyle(Colors.Yellow, Colors.Black)

			for _, name in ipairs(PlayerEntity[Boons].value) do
				ui.PushStyle(CompColors[name][1], Colors.Black)
				ui.Label("[" .. name .. "]")
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
