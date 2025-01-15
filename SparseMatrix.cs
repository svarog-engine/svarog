namespace svarog
{
    public class SparseMatrix<T>
    {
        public int Width { get; private set; }
        public int Height { get; private set; }
        public long MaxSize { get; private set; }
        public long Count { get { return m_Cells.Count; } }

        private Dictionary<long, T> m_Cells = new();
        private Dictionary<int, Dictionary<int, T>> m_Rows = new();
        private Dictionary<int, Dictionary<int, T>> m_Columns = new();

        public SparseMatrix(int w, int h)
        {
            this.Width = w;
            this.Height = h;
            this.MaxSize = w * h;
        }

        public bool IsCellEmpty(int row, int col)
        {
            long index = row * Width + col;
            return m_Cells.ContainsKey(index);
        }

        public T? this[int row, int col]
        {
            get
            {
                long index = row * Width + col;
                m_Cells.TryGetValue(index, out T? result);
                return result;
            }
            set
            {
                long index = row * Width + col;
                m_Cells[index] = value;

                UpdateValue(col, row, m_Columns, value);
                UpdateValue(row, col, m_Rows, value);
            }
        }

        private void UpdateValue(int index1, int index2,
            Dictionary<int, Dictionary<int, T>> parent, T value)
        {
            if (!parent.TryGetValue(index1, out var dict))
            {
                parent[index2] = dict = new Dictionary<int, T>();
            }
            dict[index2] = value;
        }
    }
}
