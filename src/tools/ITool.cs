using svarog.src.windowing;

namespace svarog.src.tools
{
    public interface ITool
    {
        string Name { get; set; }
        void Render(IWindow window);
    }
}
