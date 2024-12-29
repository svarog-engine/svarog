using svarog.src.inputs;

namespace svarog.src.windowing
{
    public interface IWindow
    {
        Keyboard GetKeyboard();
        Mouse GetMouse();
        Svarog GetCore();
    }
}
