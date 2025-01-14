using CommandLine;

using Serilog;
using Serilog.Core;

using svarog.input;
using svarog.input.contexts;

using System.Reflection;

namespace svarog.runner
{
    public class Svarog
    {
        #region Singleton
        
        private static readonly Svarog ms_Instance = new Svarog();
        static Svarog() { }

        private Svarog() { }

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
                var assembly = Assembly.GetAssembly(typeof(Svarog))?.GetName().FullName;
                if (assembly != null)
                {
                    var presenter = Activator.CreateInstance(assembly, options.Presenter);
                    if (presenter != null)
                    {
                        m_PresentationLayer = (IPresentationLayer?)presenter.Unwrap();
                        m_PresentationLayer?.Create(options);
                        Svarog.Instance.LogInfo($"Svarog presenter class ({options.Presenter}) instantiated successfully.");
                    }
                    else
                    {
                        Svarog.Instance.LogFatal($"Svarog presenter class ({options.Presenter}) not found. Quitting.");
                        Shutdown();
                    }
                }
                else
                {
                    Svarog.Instance.LogFatal("Svarog assembly is found to be null. Quitting.");
                    Shutdown();
                }
            }
        }

        #endregion Display

        //

        bool m_ShouldShutdown = false;
        InputParser m_InputParser = new();
        IPresentationLayer? m_PresentationLayer = null;

        public void EnqueueInput(IInput input) => m_InputParser.Enqueue(input);
        public void Shutdown() => m_ShouldShutdown = true;

        static void Main(string[] args)
        {
            Svarog.Instance.Run(args);
        }

        public void Run(string[] args)
        {
            Parser.Default.ParseArguments<CommandLineOptions>(args)
            .WithParsed(options =>
            {
                SetupLogging(options);

                Svarog.Instance.LogInfo("===========================================");
                Svarog.Instance.LogInfo("Starting up Svarog!");

                SetupDisplayMode(options);
            });

            m_InputParser.Contexts.Push(new DebugPrintConsumeInputContext());

            while (!m_ShouldShutdown)
            {
                m_InputParser.ProduceGameEvents();
                m_PresentationLayer?.Update();
                Thread.Yield();
            }

            Svarog.Instance.LogInfo("Shutting Svarog down!");
        }


    }
}
