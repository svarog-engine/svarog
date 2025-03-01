using svarog.runner;

namespace svarog
{
    public interface IPresentationLayer
    {
        void Create(CommandLineOptions options);
        void Reload();
        void Update();

        (int, int) GetRelativeMousePosition(int x, int y);
    }
}
