using svarog.runner;

namespace svarog.core
{
    public interface IPresentationLayer
    {
        void Create(CommandLineOptions options);
        void Reload();
        void Update();
    }
}
