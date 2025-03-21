
local DeathRenderSystem = Engine.RegisterUIRenderSystem("Death Render");

function DeathRenderSystem:ShouldRender()
	return PlayerEntity[Death] ~= nil or PlayerEntity[Win] ~= nil
end

function DeathRenderSystem.Render(ui)
	ui.FillRect(4, 12, Config.Width - 21, 9, Colors.Black)
	ui.PushBox(5, 13, Config.Width - 20, 8)
		if PlayerEntity[Death] ~= nil then
			ui.PushOrder("|")
				ui.Label("=    " .. PlayerEntity[Death].reason .. "    =")
				ui.Space(1)
				ui.Label("You died! Hold <SPACE> to be reborn.")
			ui.PopOrder()
		else
			ui.PushOrder("|")
				ui.Label("=    You tame the glyph of [HATE]!    =")
				ui.Space(1)
				ui.Label("     If only it could ever again be    ")
				ui.Label("         released into the world...    ")
				ui.Space(1)
				ui.Label("  YOU WIN! Hold <SPACE> to be reborn.  ")
			ui.PopOrder()
		end

		ui.PushOrder("|")
			ui.Space(1)
			ui.PushOrder("-")
				ui.Label("      ")
				local max, current = Input.HoldRatio("Reload")
				ui.Bar("", current, max, { width = 20 })
			ui.PopOrder()
		ui.PopOrder()
	ui.PopBox()
end
