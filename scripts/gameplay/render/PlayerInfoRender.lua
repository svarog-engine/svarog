
local PlayerInfoRenderSystem = Engine.RegisterUIRenderSystem("Player Info Render");

local Components = { 
	Health = Health, 
	Telepathic = Telepathic, 
	Invisible = Invisible,
	Delayed = Delayed,
	Blindness = Blindness,
}

-- optimize this crap
local function GetWheelsEntries()
	local entries = {}
	for i = 1, 12 do
		name, component = Wheels:GetMajor(i)
		table.insert(entries, {name = name, component = component})
	end

	for i = 1, 12 do
		name, component = Wheels:GetMinor(i)
		table.insert(entries, {name = name, component = component})
	end

	return entries
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
			for _, wheelItem in pairs(GetWheelsEntries()) do
				local v = player[wheelItem.component]
				if v ~= nil then
					ui.Label(wheelItem.name)
				end
			end
			ui.PopStyle()
			
			ui.Space(1)

			for name, comp in pairs(Components) do
				local v = player[comp]
				if v ~= nil then
					ui.Bar(name, v.current, v.maximum, { width = v.maximum })
				end
			end
		ui.PopOrder()
	ui.PopBox()
end
