
local DeathRenderSystem = Engine.RegisterUIRenderSystem("Death Render");

function DeathRenderSystem:ShouldRender()
	return PlayerEntity[Death] ~= nil or PlayerEntity[Win] ~= nil
end

function DeathRenderSystem.Render(ui)
	ui.FillRect(4, 12, Config.Width - 21, 9, Colors.DarkMagenta)
	ui.PushBox(5, 13, Config.Width - 20, 8)
		ui.PushStyle(Colors.White, Colors.DarkMagenta)
			local v = 0
			if PlayerEntity[Death] ~= nil then
				ui.PushOrder("|")
					ui.Label("=    " .. PlayerEntity[Death].reason .. "    =")
					ui.Space(1)
					ui.Label("You died! Hold <SPACE> to be reborn.")
				ui.PopOrder()
				v = 4
			else
				ui.PushOrder("|")
					ui.Label("=    You tame the glyph of [HATE]!    =")
					ui.Space(1)
					ui.Label("     If only it could ever again be    ")
					ui.Label("         released into the world...    ")
					ui.Space(1)
					ui.Label("  YOU WIN! Hold <SPACE> to be reborn.  ")
				ui.PopOrder()
				v = 1
			end

			ui.PushOrder("|")
				ui.Space(v)
				ui.PushOrder("-")
					ui.Label("      ")
					local max, current = Input.HoldRatio("Reload")
					ui.Bar("", current, max, { width = 22 })
				ui.PopOrder()
			ui.PopOrder()
		ui.PopStyle()
	ui.PopBox()
end
