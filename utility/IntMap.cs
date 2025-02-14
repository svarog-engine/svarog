namespace svarog.utility
{
    public class IntMap : IMap<int, IntMap>
    {
        private readonly int m_Width;
        private readonly int m_Height;
        private readonly int[,] m_Map;

        public int[,] Values => m_Map;
        public int Width => m_Width;
        public int Height => m_Height;

        public IntMap(int width, int height, int value = 0)
        {
            m_Width = width;
            m_Height = height;
            m_Map = new int[width, height];
            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    m_Map[i, j] = value;
                }
            }
        }

        public IntMap Create(int w, int h)
        {
            return new IntMap(w, h);
        }
    }
}
