using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace svarog
{
    public class SparseMatrix<T>
    {
        public int Width { get; private set; }
        public int Height { get; private set; }
        public long MaxSize { get; private set; }
        public long Count { get { return _cells.Count; } }

        private Dictionary<long, T> _cells = new Dictionary<long, T>();

        private Dictionary<int, Dictionary<int, T>> _rows =
            new Dictionary<int, Dictionary<int, T>>();

        private Dictionary<int, Dictionary<int, T>> _columns =
            new Dictionary<int, Dictionary<int, T>>();

        public SparseMatrix(int w, int h)
        {
            this.Width = w;
            this.Height = h;
            this.MaxSize = w * h;
        }

        public bool IsCellEmpty(int row, int col)
        {
            long index = row * Width + col;
            return _cells.ContainsKey(index);
        }

        public T this[int row, int col]
        {
            get
            {
                long index = row * Width + col;
                T result;
                _cells.TryGetValue(index, out result);
                return result;
            }
            set
            {
                long index = row * Width + col;
                _cells[index] = value;

                UpdateValue(col, row, _columns, value);
                UpdateValue(row, col, _rows, value);
            }
        }

        private void UpdateValue(int index1, int index2,
            Dictionary<int, Dictionary<int, T>> parent, T value)
        {
            Dictionary<int, T> dict;
            if (!parent.TryGetValue(index1, out dict))
            {
                parent[index2] = dict = new Dictionary<int, T>();
            }
            dict[index2] = value;
        }
    }
}
