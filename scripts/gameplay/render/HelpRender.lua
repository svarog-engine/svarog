

local HelpRenderSystem = Engine.RegisterUIRenderSystem("Help Render");

local boxes = {}

function HelpRenderSystem:ShouldRender(ui)
	return ShowHelpWindow
end

function HelpRenderSystem.Render(ui)
	local w, h = Dungeon.floor:Size()	
	ui.ClearBox(1, 1, w, h)
	ui.FillRect(1, 1, w, h)

	ui.PushBox(2, 2, 20, 20)
		ui.PushOrder("|")
			ui.Label(" [ CONTROLS ]")
			ui.Space(1)
			ui.Label(" - Movement -")
			ui.Space(1)
			ui.Label("  ARROWS.......move")
			ui.Label("  SHIFT........jump")
			ui.Label("  SPACE........wait")

			ui.Space(1)

			ui.Label(" - Info -")
			ui.Space(1)
			ui.Label("  hold ALT.....scan")
			ui.Label("  TAB.........diary")
			ui.Label("  I.......inventory")

			ui.Space(1)

			ui.Label(" - Game -")
			ui.Space(1)
			ui.Label("  F1...........help")
			ui.Label("  hold F10.....exit")
		ui.PopOrder()
	ui.PopBox()

	
	ui.PushBox(25, 2, 20, 20)
		ui.PushOrder("|")
			ui.Label(" [ CONTROLS ]")
			ui.Space(1)
			ui.Label(" - Movement -")
			ui.Space(1)
			ui.Label("  ARROWS.......move")
			ui.Label("  SHIFT........jump")
			ui.Label("  SPACE........wait")

			ui.Space(1)

			ui.Label(" - Info -")
			ui.Space(1)
			ui.Label("  hold ALT.....scan")
			ui.Label("  TAB.........diary")
			ui.Label("  I.......inventory")

			ui.Space(1)

			ui.Label(" - Game -")
			ui.Space(1)
			ui.Label("  F1...........help")
			ui.Label("  hold F10.....exit")
		ui.PopOrder()
	ui.PopBox()
end
