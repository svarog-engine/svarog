using SFML.Graphics;

namespace svarog.utility
{
    internal static class SFMLExtensions
    {
        public static void SetWindowSize(this RenderWindow window, uint width, uint height)
        {
            window.Size = new SFML.System.Vector2u(width, height);
        }
    }
}