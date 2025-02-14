using SFML.System;

namespace svarog.utility
{
    public interface INeighborhood
    {
        public int Width { get; }
        public int Height { get; }
        public ICollection<Vector2i> GetNeighborhood();
    }
}
