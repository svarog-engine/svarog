using svagui.platform;

using svarog.src.inputs;
using svarog.src.render;

namespace svarog.src.windowing
{
    public interface IWindow
    {
        Keyboard GetKeyboard();
        Mouse GetMouse();
        Svarog GetCore();
        SFMLGUIPlatform GetGUI();
    }
}
