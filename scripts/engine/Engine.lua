Config = {
    Font = "whitrabt",
    FontSize = 12,
    
    WorldWidth = 80,
    WorldHeight = 60,

    RenderTime = 166,
}

World = ECS.World()

Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

RenderChangelist = {}

local FrameCount = 0

local function Draw(change)
    table.insert(RenderChangelist, change)
end

local function Glyph(x, y, glyph, fg, bg)
    Engine.Draw({ X = x, Y = y, Presentation = glyph or ".", Foreground = fg or Colors.Yellow, Background = bg or Colors.Red })
end 

local function Write(x, y, text, fg, bg)
    for i = 0, #text - 1 do
        Engine.Glyph(x + i, y, string.sub(text, i + 1, i + 1), fg, bg)
    end 
end

local function RenderPass()
	for i, c in ipairs(RenderChangelist) do
		if c.Presentation ~= nil then Glyphs[c.X][c.Y].Presentation = c.Presentation end
		if c.Foreground ~= nil then Glyphs[c.X][c.Y].Foreground = c.Foreground end
		if c.Background ~= nil then Glyphs[c.X][c.Y].Background = c.Background end
	end
	RenderChangelist = {}
end

local function UpdateWorld(time)
    if World then
        World:Update("process", time)
        World:Update("transform", time)

        if not Options.Headless and Svarog:ShouldRedraw() then
            World:Update("render", time)
            RenderPass()
            Svarog:ResetRedraw()
        end
    end
end

local function NextFrame()
    Input.Update()
    FrameCount = FrameCount + 1
    UpdateWorld(FrameCount)
end

local function Setup()
    InputEntity = World:Entity()

    print("Adding systems to world ", World)
    for _, v in ipairs(Pipeline_Player) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Enviro) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Render) do World:AddSystem(v) end

    for _, v in ipairs(Pipeline_Startup) do
        v() 
    end
end

local function Reload()
    print("Destroying world: ", World)
    World:Destroy()
    World = nil

    World = ECS.World()

    print("Creating world:", World)

    Pipeline_Startup = {}
    Pipeline_Player = {}
    Pipeline_Enviro = {}
    Pipeline_Render = {}

    FrameCount = 0
    Input.Clear()
    
    Svarog.Instance:ReloadConfig()
    Svarog.Instance:ReloadGlyphs()

    InputStack:ReloadActions()
    Svarog.Instance:RunScriptMain()
    Setup()
end

function PlayerSystem() return "process" end
function WorldSystem() return "transform" end
function RenderSystem() return "render" end

function RegisterPlayerSystem()
    local system = ECS.System(Engine.PlayerSystem())
    system.Order = #Pipeline_Player
    table.insert(Pipeline_Player, system)
    return system
end

function RegisterEnviroSystem()
    local system = ECS.System(Engine.WorldSystem())
    system.Order = #Pipeline_Enviro
    table.insert(Pipeline_Enviro, system)
    return system
end

function RegisterRenderSystem(q)
    if q == nil then q = function(id) return id end end
    local system = ECS.System(Engine.RenderSystem(), q(ECS.Query.All(Redraw)), function(self)
        if next(self:Result():ToArray()) ~= nil then
            self:Render()
        end
    end)
    system.Order = #Pipeline_Render
    table.insert(Pipeline_Render, system)
    return system
end

function RegisterInputSystem(inputs, fn)
    local system = ECS.System(Engine.PlayerSystem(), ECS.Query.Any(table.unpack(inputs)), function(self) 
        for _, e in self:Result(self.queryAction):Iterator() do
		    fn(e)
            for _, i in ipairs(inputs) do
                Input.Consume(i)
            end
	    end
    end)

    table.insert(Pipeline_Player, system)
end

function OnStartup(fun) 
    table.insert(Pipeline_Startup, fun)
end

return {
    Draw = Draw,
    Glyph = Glyph,
    Write = Write,
    Setup = Setup,
    Reload = Reload,
    Frame = function() return FrameCount end,
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    OnStartup = OnStartup,
    RegisterPlayerSystem = RegisterPlayerSystem,
    RegisterInputSystem = RegisterInputSystem,
    RegisterEnviroSystem = RegisterEnviroSystem,
    RegisterRenderSystem = RegisterRenderSystem,
}