
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
    }
}
