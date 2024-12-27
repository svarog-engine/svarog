using svarog.Source.inputs;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace svarog.Source.windowing
{
    public interface IWindow
    {
        Keyboard GetKeyboard();
        Mouse GetMouse();
    }
}
