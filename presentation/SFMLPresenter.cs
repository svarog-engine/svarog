
using SFML.Graphics;
using SFML.Window;

using svarog.input.devices;
using svarog.runner;

namespace svarog.presentation
{
    internal class SFMLPresenter : IPresentationLayer
    {
        private RenderWindow? m_Window = null;

        public void Create(CommandLineOptions options)
        {
            m_Window = new RenderWindow(new SFML.Window.VideoMode(800, 600), "Svarog");
            
            m_Window.Closed += (object? _, EventArgs _) => 
            {
                m_Window.Close(); 
                Svarog.Instance.Shutdown(); 
            };

            m_Window.KeyPressed += (object? _, KeyEventArgs args) => 
            {
                Svarog.Instance.EnqueueInput(new KeyboardInput((int)args.Scancode, 1));
            };

            m_Window.KeyReleased += (object? _, KeyEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new KeyboardInput((int)args.Scancode, 0));
            };

            m_Window.MouseButtonPressed += (object? _, MouseButtonEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new MouseInput((int)args.Button, 1, args.X, args.Y));
            };

            m_Window.MouseButtonReleased += (object? _, MouseButtonEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new MouseInput((int)args.Button, 0, args.X, args.Y));
            };

            m_Window.MouseMoved += (object? _, MouseMoveEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new MouseInput(null, 0, args.X, args.Y));
            };

            Svarog.Instance.LogInfo("SFML Presenter up and running!");
        }

        public void Update()
        {
            if (m_Window != null)
            {
                m_Window.DispatchEvents();
                m_Window.Display();
            }
        }
    }
}
