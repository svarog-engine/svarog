using svarog.runner;

namespace svarog
{
    public interface IPresentationLayer
    {
        void Create(CommandLineOptions options);
        void Update();
    }
}
