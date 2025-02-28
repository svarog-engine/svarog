using CommandLine;

using NLua;
using NLua.Exceptions;

using Serilog;
using Serilog.Core;
using SFML.System;
using svarog.input;
using svarog.presentation;
using svarog.utility;

using System.Diagnostics;
using System;
using System.Web;
using svarog.procgen.rewriting;
using svarog.utility.filesystem;
using System.Reflection;
using System.Reflection.PortableExecutable;

namespace svarog.runner
{
    public class Svarog
    {
        #region Singleton

        private static readonly Svarog ms_Instance = new Svarog();
        static Svarog() { }

        public static Svarog Instance => ms_Instance;

        #endregion Singleton

        #region Logging

        private Logger? m_Logger = null;

        public void LogVerbose(string message) => m_Logger?.Verbose(message);
        public void LogDebug(string message) => m_Logger?.Debug(message);
        public void LogInfo(string message) => m_Logger?.Information(message);
        public void LogWarning(string message) => m_Logger?.Warning(message);
        public void LogError(string message) => m_Logger?.Error(message);
        public void LogFatal(string message) => m_Logger?.Fatal(message);

        private void SetupLogging(CommandLineOptions options)
        {
            if (options.Logging)
            {
                m_Logger = new LoggerConfiguration()
                    .MinimumLevel.Information()
                    .WriteTo.Console()
                    .WriteTo.Debug()
                    .WriteTo.File("log.txt", Serilog.Events.LogEventLevel.Debug)
                    .CreateLogger();
            }
        }

        #endregion Logging

        #region Display

        private void SetupDisplayMode(CommandLineOptions options)
        {
            if (options.Headless && !options.InputPort.HasValue)
            {
                Svarog.Instance.LogError("Cannot run headless mode without an input port for events. Shutting down.");
                m_ShouldShutdown = true;
            }
            else if (options.Headless && options.InputPort.HasValue)
            {
                Svarog.Instance.LogInfo($"Preparing for headless mode using port #{options.InputPort.Value} for inputs.");
            }
            else if (options.InputPort.HasValue)
            {
                Svarog.Instance.LogInfo($"Using port #{options.InputPort.Value} as an aux input port (handy for debugging).");
            }

            if (!options.Headless)
            {
                var parts = options.Presenter.Split(",", 2);
                var presenter = Activator.CreateInstance(parts[1].Trim(), parts[0].Trim());
                if (presenter != null)
                {
                    m_PresentationLayer = (IPresentationLayer?)presenter.Unwrap();
                    Svarog.Instance.LogInfo($"Svarog presenter class ({options.Presenter}) instantiated successfully.");
                }
                else
                {
                    Svarog.Instance.LogFatal($"Svarog presenter class ({options.Presenter}) not found. Quitting.");
                    Shutdown();
                }
            }
        }

        #endregion Display

        #region Scripting

        public void RunScriptMain()
        {
            RunScriptFile("scripts\\Main");
        }

        public void RunScript(string code)
        {
            try
            {
                m_Lua.DoString(code);
            }
            catch (LuaScriptException scriptingException)
            {
                var cs = m_Lua["CurrentSystem"] as SystemTracker;
                LogError("[ in " + cs?.Name + " ] " + scriptingException.ToString());
            }
            catch (LuaException luaException)
            {
                var cs = m_Lua["CurrentSystem"] as SystemTracker;
                LogError("[ in " + cs?.Name + " ] " + luaException.ToString());
            }
        }

        public void RunScriptFile(string filename)
        {
            var code = "";
            if (m_FileSystem != null)
            {
                code = m_FileSystem.GetFileContent(filename + ".lua");
            }

            RunScript(code);
        }

        public void RunScriptFileIfExists(string filename)
        {
            if (m_FileSystem == null || !m_FileSystem.FileExists(filename + ".lua"))
                return;

            var code = "";
            if (m_FileSystem != null)
            {
                code = m_FileSystem.GetFileContent(filename + ".lua");
            }

            RunScript(code);
        }

        public void RequireModule(string modulePath, string moduleName)
        {
            RunScript($"package.preload[\"{moduleName}\"] = function () {m_FileSystem?.GetFileContent(modulePath + ".lua")} end");
        }

        #endregion Scripting

        bool m_ShouldShutdown = false;

        readonly Lua m_Lua;

        public Lua Scripting => m_Lua;

        readonly InputManager m_InputManager;
        IPresentationLayer? m_PresentationLayer = null;

        IFileSystem? m_FileSystem = null;
        public IFileSystem? FileSystem => m_FileSystem;

        private Glyph[][] m_Glyphs;
        private Glyph[][] m_UIGlyphs;

        public Glyph[][] Glyphs => m_Glyphs;
        public Glyph[][] UIGlyphs => m_UIGlyphs;

        private Clock m_Clock = new Clock();
        long m_FrameTime = 0;
        long m_RenderFrameTime = 0;
        int m_Counter = 0;

        private bool m_Redraw = true;
        public bool ShouldRedraw() => m_Redraw;
        public void Redraw() { m_Redraw = true; }
        public void ResetRedraw() { m_Redraw = false; }

        private bool m_Reload = false;
        public void Reload() { m_Reload = true; }

        private PcgInterpreter<PcgResolution_RandomPick> m_PCG = new(new PcgGraphStorage());
        public PcgInterpreter<PcgResolution_RandomPick> PCG => m_PCG;

        public void ReloadPCG()
        {
            m_PCG.Clear();
        }

        public void ReloadConfig()
        {
            RunScriptFile("scripts\\engine\\DefaultConfig");
            RunScriptFile("scripts\\Config");
        }

        public void ReloadGlossary()
        {
            Svarog.Instance.LogInfo("Loading glossary");
            RunScriptFile("scripts\\engine\\Presentation");
            RunScript("Glossary = {}");
            RunScript("Glossary.Meta = {}");
            m_Colors = new();
            m_Lua["Colors"] = m_Colors;
            if (m_Lua["Config.Palette"] is string palette)
            {
                RunScriptFile($"scripts\\presentation\\palettes\\{palette}");
            }
            RunScriptFile("scripts\\presentation\\Glossary");
        }

        public void ReloadLayers()
        {
            ReloadGlyphs();
            ReloadUIGlyphs();
        }

        public void ReloadGlyphs()
        {
            var width = (int)((double)m_Lua["Config.Width"]);
            var height = (int)((double)m_Lua["Config.Height"]);
            m_Glyphs = new Glyph[width][];

            for (int i = 0; i < width; i++)
            {
                m_Glyphs[i] = new Glyph[height];
                for (int j = 0; j < height; j++)
                {
                    m_Glyphs[i][j] = new Glyph(Colors.Black, Colors.Black);
                }
            }
            m_Lua["Glyphs"] = m_Glyphs;
        }

        public void ReloadUIGlyphs()
        {
            var width = (int)((double)m_Lua["Config.Width"]);
            var height = (int)((double)m_Lua["Config.Height"]);
            m_UIGlyphs = new Glyph[width][];

            for (int i = 0; i < width; i++)
            {
                m_UIGlyphs[i] = new Glyph[height];
                for (int j = 0; j < height; j++)
                {
                    m_UIGlyphs[i][j] = new Glyph();
                }
            }
            m_Lua["UIGlyphs"] = m_UIGlyphs;
        }

        public void ReloadPresenter()
        {
            m_PresentationLayer?.Reload();
        }

        float m_Delta = 0.0f;
        public float DeltaTime => m_Delta;

        Colors m_Colors;
        internal Colors Colors => m_Colors;

        public void EnqueueInput(InputAction input)
        {
            m_InputManager.Enqueue(input);
        }

        public void Shutdown() => m_ShouldShutdown = true;

        private Svarog()
        {
            m_Lua = new();
            m_InputManager = new();
        }

        static void Main(string[] args)
        {
            Svarog.Instance.Run(args);
        }

        public void Run(string[] args)
        {
            var commandLine = Parser.Default.ParseArguments<CommandLineOptions>(args);

            commandLine.WithParsed(options =>
            {
                m_Lua["Options"] = options;
                SetupLogging(options);

                Svarog.Instance.LogInfo("===========================================");
                Svarog.Instance.LogInfo("Starting up Svarog!");

                SetupDisplayMode(options);

                if (Path.Exists("data.bin"))
                {
                    Svarog.Instance.LogInfo("Running binarized data");
                    m_FileSystem = new BinFileSystem();
                }
                else
                {
                    Svarog.Instance.LogInfo("Running non-binarized data");
                    m_FileSystem = new RawFileSystem();
                }

            });

            m_Lua.LoadCLRPackage();
            m_Lua["Svarog"] = this;
            m_Lua["Rand"] = new Randomness();
            m_Lua["InputStack"] = m_InputManager;
            m_Lua["ActionTriggers"] = m_InputManager.Triggered;
            m_Lua["PCG"] = m_PCG;
            m_Lua["CurrentSystem"] = new SystemTracker();

            RequireModule("scripts\\engine\\Map", "Map");
            RunScript(@"Map = require 'Map'");

            RequireModule("scripts\\engine\\DistanceMap", "DistanceMap");
            RunScript(@"DistanceMap = require 'DistanceMap'");

            RequireModule("scripts\\engine\\Queue", "Queue");
            RunScript(@"Queue = require 'Queue'");

            RequireModule("scripts\\engine\\ecs\\ECS", "ECS");
            RunScript(@"ECS = require 'ECS'");

            RequireModule("scripts\\engine\\Engine", "Engine");
            RunScript(@"Engine = require 'Engine'");

            RequireModule("scripts\\engine\\Input", "Input");
            RunScript(@"Input = require 'Input'");

            ReloadPCG();
            ReloadConfig();
            ReloadGlossary();
            ReloadLayers();

            m_InputManager.ReloadActions();
            commandLine.WithParsed(options => m_PresentationLayer?.Create(options));

            RunScriptFile("scripts\\Library");
            RunScriptMain();
            RunScript(@"Engine.Setup()");

            Svarog.Instance.LogInfo("Scripting ECS up and running!");

            while (!m_ShouldShutdown)
            {
                m_InputManager.Clear();
                m_Clock.Restart();

                if (m_Reload)
                {
                    RunScript(@"Engine.Reload()");
                    m_Reload = false;
                }

                m_InputManager.Update();
                m_PresentationLayer?.Update();

                RunScript(@"Engine.Update()");
                m_Counter++;
                m_Delta = m_Clock.ElapsedTime.AsMilliseconds();

                m_FrameTime += (int)m_Delta;
                if (m_FrameTime >= 1000)
                {
                    LogVerbose($"FPS -- {m_Counter}");
                    m_FrameTime = 0;
                    m_Counter = 0;
                }

                m_RenderFrameTime += (int)m_Delta;
                if (m_RenderFrameTime >= (double)m_Lua["Config.FrameTime"])
                {
                    Redraw();
                    m_RenderFrameTime = 0;
                }

                Thread.Yield();
            }

            Svarog.Instance.LogInfo("Shutting Svarog down!");
        }
    }
}