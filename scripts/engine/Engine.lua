World = ECS.World()

DoMeasurements = false

Algorithms = {}

PlayerDone = true
Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

function FromList(sharp_list)
	local list = {}
	local it = sharp_list:GetEnumerator()
    while it:MoveNext() do
		table.insert(list, it.Current)
	end

	return list
end

function FromDict(sharp_dict)
	local dict = {}
	local it = sharp_dict:GetEnumerator()
    while it:MoveNext() do
		dict[it.Current.Key] = it.Current.Value
	end

	return dict
end

local RenderChangelist = { Game = {}, UI = {}}

local UpdateCount = 0
local FrameCount = 0
local Measurements = {
    last = {},
    min = {},
    max = {},
    average = {},
    averageCount = {}
}

local function ProcessLayer(changelist, matrix, pres)
    local glos = Glossary[pres]
    local type = Glossary.Meta[pres].Type
	for i, c in ipairs(changelist) do
        if matrix[c.X] ~= nil and matrix[c.X][c.Y] ~= nil then
            local item = matrix[c.X][c.Y]
            if c.Tile ~= nil then 
                local tile = glos[c.Tile]
                if tile ~= nil then
                    item.TileX = tile.x
                    item.TileY = tile.y
                    item.Foreground = tile.fg
                    item.Background = tile.bg
                end
            end

		    if c.Foreground ~= nil then item.Foreground = c.Foreground end
		    if c.Background ~= nil then item.Background = c.Background end
        end
	end
end

local function RenderPass()
    local pres = Config.Presentation or "Default"
    ProcessLayer(RenderChangelist["Game"], Glyphs, pres)
    ProcessLayer(RenderChangelist["UI"], UIGlyphs, pres)

    RenderChangelist["Game"] = {}
    RenderChangelist["UI"] = {}
end

local function Draw(change, layer)
    local renderlayer = layer or "Game"
    table.insert(RenderChangelist[renderlayer], change)
end

local function Glyph(x, y, name, overrides, layer)
    local renderlayer = layer or "Game"

    message = {}
    message.X = x - 1
    message.Y = y - 1
    message.Tile = name

    if overrides ~= nil then
        if overrides.fg ~= nil then message.Foreground = overrides.fg end
        if overrides.bg ~= nil then message.Background = overrides.bg end
    end
    
    Engine.Draw(message, renderlayer)
end 

local function Symbol(x, y, glyph, fg, bg, layer)
    local def = Config.Presentation or "Default"
    local renderlayer = layer or "Game"

    local glyphValue = glyph
    if glyph == " " then  glyphValue = "empty" end

    local overrides = {}
    if fg ~= nil then overrides.fg = fg end
    if bg ~= nil then overrides.bg = bg end
    Glyph(x, y, glyphValue, overrides, renderlayer)
end 

local function Write(x, y, text, fg, bg, layer)
    local renderlayer = layer or "Game"
    for i = 0, #text - 1 do
        Engine.Symbol(x + i, y, string.sub(text, i + 1, i + 1), fg, bg, renderlayer)
    end 
end

local function Line(row, char, fg, bg, layer)
    local renderlayer = layer or "Game"

	for i = 0, Config.Width - 1 do
		Glyph(i, row, char, { Foreground = fg or Colors.White, Background = bg or Colors.Black}, renderlayer)
	end
end

local function UpdateWorld(time)
    if World then
        World:Update(PlayerSystem(), time)

        if PlayerDone then
            UpdateCount = UpdateCount + 1
            PlayerDone = false
            if DoMeasurements then
                print ("+-------------------------------+")
                print ("|  Frame #" .. string.format("%16i", UpdateCount) .. "      |")
                print ("+-------------------------------+---------+---------+---------+---------+")
                print ("|       SYSTEM                  |   NOW   |   MIN   |   MAX   |   AVG   |")
                print ("+-------------------------------+---------+---------+---------+---------+")
            end
            World:Update(WorldSystem(), time)
            if DoMeasurements then
                print ("+-------------------------------+---------+---------+---------+---------+")
            end
        end

        if not Options.Headless and Svarog:ShouldRedraw() then
            World:Update(RenderSystem(), time)
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

    for _, v in ipairs(Pipeline_Player) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Enviro) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Render) do World:AddSystem(v) end

    for _, v in ipairs(Pipeline_Startup) do
        v() 
    end
end

local function Reload()
    World:Destroy()
    World = nil

    World = ECS.World()

    PlayerDone = true

    Pipeline_Startup = {}
    Pipeline_Player = {}
    Pipeline_Enviro = {}
    Pipeline_Render = {}

    local Measurements = {
        last = {},
        min = {},
        max = {},
        average = {},
        averageCount = {}
    }

    FrameCount = 0
    Input.Clear()
    
    Svarog.Instance:ReloadConfig()
    Svarog.Instance:ReloadGlossary()
    Svarog.Instance:ReloadLayers()
    Svarog.Instance:ReloadPresenter()

    InputStack:ReloadActions()
    Svarog:RunScriptFile("scripts\\Library")
    Svarog.Instance:RunScriptMain()
    Setup()
end

function StartMeasure()
    if DoMeasurements then
        start_time = os.clock()
    end
end

function EndMeasure(name)
    if DoMeasurements then
	    end_time = os.clock()
        elapsed_time = end_time - start_time
        Measurements.last[name] = elapsed_time
        Measurements.min[name] = math.min(Measurements.min[name] or 10000, elapsed_time)
        Measurements.max[name] = math.max(Measurements.max[name] or -1, elapsed_time)
        if Measurements.average[name] == nil then
            Measurements.average[name] = elapsed_time
            Measurements.averageCount[name] = 1
        else
            local avg = Measurements.average[name]
            local c = Measurements.averageCount[name]
            Measurements.average[name] = (elapsed_time + avg * c) / (c + 1)
            Measurements.averageCount[name] = c + 1
        end

        local min = Measurements.min[name]
        local max = Measurements.max[name]
        local avg = Measurements.average[name]
        print(string.format("|%29s  | %.4fs | %.4fs | %.4fs | %.4fs |", name, elapsed_time, min, max, avg))
    end
end

function TableLength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function PlayerSystem() return "process" end
function WorldSystem() return "transform" end
function RenderSystem() return "render" end

function RegisterPlayerSystem(name)
    local system = ECS.System(Engine.PlayerSystem())
    system.Order = #Pipeline_Player

    system.ShouldUpdate = function(time)
        CurrentSystem:Set(name)
        local value = false
        if system.ShouldTick ~= nil then
            value = system:ShouldTick(time)
        else
            Svarog.LogWarning("ShouldTick not implemented for " .. name)
        end
        CurrentSystem:Reset()
        return value
    end

    system.Update = function(self)
        CurrentSystem:Set(name)
        StartMeasure()
        if self.Tick ~= nil then
            self:Tick()
        end
        EndMeasure(name)
        CurrentSystem:Reset()
    end

    table.insert(Pipeline_Player, system)
    return system
end

function RegisterEnviroSystem(name)
    local system = ECS.System(Engine.WorldSystem())
    system.Order = #Pipeline_Enviro
    system.Name = name or ""
    
    system.ShouldUpdate = function(time)
        CurrentSystem:Set(name)
        local value = false
        if system.ShouldTick ~= nil then
            value = system:ShouldTick(time)
        else
            Svarog.LogWarning("ShouldTick not implemented for " .. name)
        end
        CurrentSystem:Reset()
        return value
    end

    system.Update = function(self)
        CurrentSystem:Set(name)
        StartMeasure()
        if self.Tick ~= nil then
            self:Tick()
        end
        EndMeasure(name)
        CurrentSystem:Reset()
    end

    table.insert(Pipeline_Enviro, system)
    return system
end

function RegisterRenderSystem(name, q)
    if q == nil then q = function(id) return id end end
    local system = ECS.System(Engine.RenderSystem(), q(ECS.Query.All(Redraw)))

    system.Order = #Pipeline_Render
    system.ShouldUpdate = function(time)
        CurrentSystem:Set(name)
        local value = false
        if system.ShouldRender ~= nil then
            value = system:ShouldRender(time)
        else
            value = true
        end
        CurrentSystem:Reset()
        return value
    end

    system.Update = function(self)
        CurrentSystem:Set(name)
        StartMeasure()
        if next(self:Result():ToArray()) ~= nil then
            if self.Render~= nil then
                self:Render()
            end
        end
        EndMeasure(name)
        CurrentSystem:Reset()
    end

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
    return system
end

function OnStartup(fun) 
    table.insert(Pipeline_Startup, fun)
end

function IncludeGameplay(name)
    Svarog:RunScriptFile("scripts\\gameplay\\" .. name)
end

function LoadPlayerSystem(name)
    Svarog:RunScriptFile("scripts\\gameplay\\player\\" .. name)
end

function LoadEnviroSystem(name)
    Svarog:RunScriptFile("scripts\\gameplay\\enviro\\" .. name)
end

function LoadRenderSystem(name)
    Svarog:RunScriptFile("scripts\\gameplay\\render\\" .. name)
end

function LoadScriptIfExists(name)
    Svarog:RunScriptFileIfExists("scripts\\" .. name)
end

function Hex(rgb)
    return Colors:Hex(rgb)
end

return {
    Draw = Draw,
    Glyph = Glyph,
    Symbol = Symbol,
    Write = Write,
    Line = Line,
    Setup = Setup,
    Reload = Reload,
    Frame = function() return FrameCount end,
    Tick = function() return UpdateCount end,
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    TaskSystem = TaskSystem,
    OnStartup = OnStartup,
    RegisterPlayerSystem = RegisterPlayerSystem,
    RegisterInputSystem = RegisterInputSystem,
    RegisterEnviroSystem = RegisterEnviroSystem,
    RegisterEnviroTaskSystem = RegisterEnviroTaskSystem,
    RegisterRenderSystem = RegisterRenderSystem,
}