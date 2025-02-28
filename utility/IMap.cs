using SFML.System;

namespace svarog.utility
{
    public interface IMap<T, M> where M: IMap<T, M>
    {
        public M Create(int w, int h);

        public T[,] Values { get; }
        public int Width { get; }
        public int Height { get; }

        public bool Has(int i, int j) => i >= 0 && j >= 0 && i < Width && j < Height;

        public T Get(int i, int j) => Values[i, j];

        public M Sub(int x, int y, int w, int h)
        {
            var sub = Create(w, h);
            for (int i = 0; i < w; i++)
            {
                for (int j = 0; j < h; j++)
                {
                    sub.Values[i, j] = Values[x + i, y + j];
                }
            }

            return sub;
        }

        public void SubFrom(IMap<T, M> large, int x, int y, int w, int h)
        {
            for (int i = 0; i < w; i++)
            {
                for (int j = 0; j < h; j++)
                {
                    Values[i, j] = large.Values[x + i, y + j];
                }
            }
        }

        public M Transform<U, N>(IMap<U, N> original, Func<U, T> proc)
            where N: IMap<U, N>
        {
            var conv = Create(original.Width, original.Height);
            for (int i = 0; i < original.Width; i++)
            {
                for (int j = 0; j < original.Height; j++)
                {
                    conv.Values[i, j] = proc(original.Values[i, j]);
                }
            }

            return conv;
        }

        public M TransformWithNeighborhood<U, N, Neighborhood>(IMap<U, N> original, Func<IMap<U, N>, T> proc)
            where N: IMap<U, N>
            where Neighborhood : INeighborhood, new()
        {
            var conv = Create(original.Width, original.Height);
            var neighborhood = new Neighborhood();
            var sub = original.Sub(0, 0, neighborhood.Width, neighborhood.Height);

            for (int i = 0; i < original.Width - neighborhood.Width / 2; i++)
            {
                for (int j = 0; j < original.Height - neighborhood.Height / 2; j++)
                {
                    sub.SubFrom(original, i, j, neighborhood.Width, neighborhood.Height);
                    conv.Values[i, j] = proc(sub);
                }
            }

            return conv;
        }

        public IntMap CreateDistanceField<Neighborhood>(ICollection<Vector2i> sources, Func<M, int> proc)
            where Neighborhood : INeighborhood, new()
        {
            return new IntMap(10, 10);
        }
    }
}
