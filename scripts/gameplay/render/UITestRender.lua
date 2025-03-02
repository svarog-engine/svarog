local UITestRender = Engine.RegisterUIRenderSystem("UI Test Render")

local elements = { "one", "two", "three", "four" }
local fruits = { { "carrots", 1 }, { "bananas", 2 }, { "oranges", 10 } }

function UITestRender.Render(ui)
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

	ui.PushBox(25, 25, 30, 30)
		ui.PushOrder("|")
			ui.List(elements, 1)
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(35, 25, 30, 30)
		ui.PushOrder("|")
			ui.List(fruits, 3, function(e)
				ui.Label(e[1])
				ui.Label("  " .. tostring(e[2]) .. "/10")
				ui.Space(1)
			end)
		ui.PopOrder()
	ui.PopBox()

	ui.PushBox(45, 25, 13, 30)
		ui.PushOrder("|")
			ui.List(fruits, 2, function(e)
				ui.Bar(e[1], e[2], 10, { width = 10 })
			end)
		ui.PopOrder()
	ui.PopBox()
end