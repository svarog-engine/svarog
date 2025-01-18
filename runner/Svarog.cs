using CommandLine;

using NLua;
using NLua.Exceptions;

using Serilog;
using Serilog.Core;
using SFML.System;
using svarog.input;
using svarog.presentation;
using svarog.utility;

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

        public void RunScript(string code)
        {
            try
            {
                m_Lua.DoString(code);
            }
            catch (LuaScriptException scriptingException)
            {
                LogError(scriptingException.ToString());
            }
            catch (LuaException luaException)
            {
                LogError(luaException.ToString());
            }
        }

        public void RunScriptFile(string filename)
        {
            try
            {
                m_Lua.DoFile(filename);
            }
            catch (LuaScriptException scriptingException)
            {
                LogError(scriptingException.ToString());
            }
            catch (LuaException luaException)
            {
                LogError(luaException.ToString());
            }
        }

        #endregion Scripting

        bool m_ShouldShutdown = false;

        readonly Lua m_Lua;
        readonly InputParser m_InputParser;
        IPresentationLayer? m_PresentationLayer = null;

        private Glyph[][] m_Glyphs;

        public Glyph[][] Glyphs => m_Glyphs;

        private Clock clock = new Clock();
        long time = 0;
        int counter = 0;

        public void EnqueueInput(IInput input)
        {
            m_InputParser.Enqueue(input);
        }

        public void Shutdown() => m_ShouldShutdown = true;

        private Svarog()
        {
            m_InputParser = new();
            m_Lua = new();
        }

        static void Main(string[] args)
        {
            Svarog.Instance.Run(args);
        }

        public void Run(string[] args)
        {
            Parser.Default.ParseArguments<CommandLineOptions>(args)
            .WithParsed(options =>
            {
                m_Lua["Options"] = options;
                SetupLogging(options);

                Svarog.Instance.LogInfo("===========================================");
                Svarog.Instance.LogInfo("Starting up Svarog!");

                SetupDisplayMode(options);
                var width = options.WorldWidth.GetValueOrDefault();
                var height = options.WorldHeight.GetValueOrDefault();
                m_Glyphs = new Glyph[width][];

                for (int i = 0; i < options.WorldWidth; i++)
                {
                    m_Glyphs[i] = new Glyph[height];
                    for (int j = 0; j < options.WorldHeight; j++)
                    {
                        m_Glyphs[i][j] = new Glyph();
                    }
                }

                m_PresentationLayer?.Create(options);
            });

            m_Lua.LoadCLRPackage();
            m_Lua["Rand"] = new Randomness();
            m_Lua["Glyphs"] = m_Glyphs;
            m_Lua["Colors"] = new Colors();

            RunScript(@"require ""ECS""");
            RunScript(@"Engine = require ""scripts\\Engine""");
            RunScriptFile("scripts\\Main.lua");
            RunScript("Engine.Setup()");

            Svarog.Instance.LogInfo("Scripting ECS up and running!");

            while (!m_ShouldShutdown)
            {
                clock.Restart();
                m_InputParser.ProduceGameEvents();
                m_PresentationLayer?.Update();

                counter++;
                time += clock.ElapsedTime.AsMilliseconds();

                if (time >= 1000)
                {
                    LogInfo($"FPS -- {counter}");
                    time = 0;
                    counter = 0;
                }

                RunScript("Engine.Update()");
                Thread.Yield();
            }

            Svarog.Instance.LogInfo("Shutting Svarog down!");
        }
    }
}
