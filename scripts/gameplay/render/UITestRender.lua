local UITestRender, TargetUI = Engine.RegisterUIRenderSystem("UI Test Render")

function UITestRender.UIRender(ui)
	ui.PushBox(10, 10, 40, 40)
		ui.PushOrder("-")
			ui.Label("Hello")
			ui.Space(5)
			ui.Label("world")
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(10, 11, 40, 40)
		ui.PushOrder("-")
			ui.Label("Hello     world")
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(40, 10, 10, 40)
		ui.PushOrder("|")
			ui.Label("HelloHelloHelloHelloHello")
			ui.Space(5)
			ui.Label("worldworldworldworldworld")
		ui.PopOrder()
	ui.PopBox()

	ui.Line(5, 5, 25, 33)
	ui.Rect(15, 15, 20, 20)
end