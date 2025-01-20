
using CommandLine;

namespace svarog.runner
{
    public class CommandLineOptions
    {
        [Option('h', "headless", Default = false, Required = false, HelpText = "Enter headless mode (simulation with no presentation).")]
        public bool Headless { get; set; }

        [Option('i', "input-port", Default = null, Required = false, HelpText = "Auxiliary port for receiving input events through Lua.")]
        public int? InputPort { get; set; }

        [Option('c', "config-file", Default = "config.lua", Required = false, HelpText = "Name of the general configuration file.")]
        public string? ConfigFile { get; set; }

        [Option('l', "logging", Default = true, Required = false, HelpText = "Enables or disables extensive logging.")]
        public bool Logging { get; set; }

        [Option('p', "presenter", Default = "svarog.presentation.SFMLPresenter, svarog, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null", Required = false, HelpText = "Name of the presenter to use to render the game. Defaults to SFML.")]
        public string Presenter { get; set; }

        [Option('f', "font", Default = "AppleII", Required = false, HelpText = "Sets default font")]
        public string? Font { get; set; }

        [Option("font-size", Default = 10u, Required = false, HelpText = "Sets default font size")]
        public uint? FontSize { get; set; }

        [Option("world-width", Default = 80, Required = false, HelpText = "Sets world width")]
        public int? WorldWidth { get; set; }

        [Option("world-height", Default = 60, Required = false, HelpText = "Sets world height")]
        public int? WorldHeight { get; set; }
    }
}
