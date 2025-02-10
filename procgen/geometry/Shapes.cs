using SFML.System;

namespace svarog.procgen.geometry
{
    public interface IShape
    {
        IShape Intersect(IShape other);
        HashSet<Vector2f> Discretize();
    }

    public static class ShapeIntersections
    {
        public static IShape LineAndLine(Line a, Line b)
        {
            var a1 = a.B.Y - a.A.Y;
            var b1 = a.A.X - a.B.X;
            var c1 = a1 * a.A.X + b1 * a.A.Y;

            var a2 = b.B.Y - b.A.Y;
            var b2 = b.A.X - b.B.X;
            var c2 = a2 * b.A.X + b2 * b.A.Y;

            var det = a1 * b2 - a2 * b1;

            if (det == 0)
            {
                return a;
            }

            var x = (b2 * c1 - b1 * c2) / det;
            var y = (a1 * c2 - a2 * c1) / det;
            return new PointSet([ new Vector2f(x, y) ]);
        }

        public static IShape LineAndCircle(Line a, Circle b)
        {
            float sgn(float d)
            {
                if (d < 0) return -1;
                else return 1;
            }

            var dx = a.B.X - a.A.X;
            var dy = a.B.Y - a.B.X;
            float dr = MathF.Sqrt(dx * dx + dy * dy);
            var d = a.A.X * a.B.Y - a.B.X * a.A.Y;
            var dis = b.Radius * b.Radius * dr * dr - d * d;

            var sdis = MathF.Sqrt(dis);
            var x1 = d * dy - sgn(dy) * dx * sdis;
            var x2 = d * dy + sgn(dy) * dx * sdis;
            var y1 = -d * dx - Math.Abs(dy) * sdis;
            var y2 = -d * dx + Math.Abs(dy) * sdis;
            if (dis < 0.0) return new PointSet([]);
            else if (dis == 0.0) return new PointSet([ new Vector2f(x1, y1) ]);
            return new PointSet([ new Vector2f(x1, y1), new Vector2f(x2, y2) ]);
        }

        public static IShape LineAndRectangle(Line a, Rectangle r)
        {
            var tl = new Vector2f(MathF.Min(r.A.X, r.B.X), MathF.Min(r.A.Y, r.B.Y));
            var br = new Vector2f(MathF.Max(r.A.X, r.B.X), MathF.Max(r.A.Y, r.B.Y));
            var wh = new Vector2f(MathF.Abs(r.A.X - r.B.X), MathF.Abs(r.A.Y - r.B.Y));
            var l1 = new Line(tl, tl + new Vector2f(wh.X, 0));
            var l2 = new Line(tl, tl + new Vector2f(0, wh.Y));
            var l3 = new Line(br, br - new Vector2f(wh.X, 0));
            var l4 = new Line(br, br - new Vector2f(0, wh.Y));
            var list = new List<IShape>();
            var points = new HashSet<Vector2f>();

            foreach (var li in new List<Line>() { l1, l2, l3, l4 })
            {
                var ll = LineAndLine(a, li);
                if (ll is PointSet ps) points.UnionWith(ps.Points);
                else list.Add(li);
            }

            if (points.Count > 0)
            {
                return new And([.. list, new PointSet(points)]);
            }
            else
            {
                return new And([.. list]);
            }
        }

        public static IShape CircleAndCircle(Circle a, Circle b)
        {
            void IntersectionTwoCircles(float c1x, float c1y, float r1, float c2x, float c2y, float r2,
                out int count, out List<Vector2f> solutions)
            {
                solutions = new List<Vector2f>();
                float dx = c1x - c2x;
                float dy = c1y - c2y;
                float d = MathF.Sqrt(dx * dx + dy * dy);
                if (Math.Abs(r1 - r2) <= d && d <= r1 + r2)
                {
                    count = 0;
                    return;
                }

                float gamma1 = MathF.Acos((r2 * r2 + d * d - r1 * r1) / (2 * r2 * d));
                float d1 = r1 * MathF.Cos(gamma1);
                float h = r1 * MathF.Sin(gamma1);
                float px = c1x + (c2x - c1x) / d * d1;
                float py = c1y + (c2y - c1y) / d * d1;

                var p1 = new Vector2f(px + (-dy) / d * h, py + (+dx) / d * h);
                var p2 = new Vector2f(px - (-dy) / d * h, py - (+dx) / d * h);
                if (p1 == p2)
                {
                    count = 1;
                    solutions.Add(p1);
                }
                else
                {
                    count = 2;
                    solutions.Add(p1);
                    solutions.Add(p2);
                }
            }

            IntersectionTwoCircles(a.Center.X, a.Center.Y, a.Radius, b.Center.X, b.Center.Y, b.Radius, out int count, out var solutions);
            HashSet<Vector2f> points = [];
            foreach (var s in solutions)
            {
                points.Add(s);
            }
            return new PointSet(points);
        }

        public static IShape RectangleAndRectangle(Rectangle ra, Rectangle rb)
        {
            static bool Intersect(Rectangle a, Rectangle b)
            {
                return (a.MinX <= b.MaxX && a.MaxX >= b.MinX) &&
                       (a.MinY <= b.MaxY && a.MaxY >= b.MinY);
            }

            if (Intersect(ra, rb))
            {
                return new Rectangle(
                    new Vector2f(MathF.Max(ra.MinX, rb.MinX), MathF.Max(ra.MinY, rb.MinY)),
                    new Vector2f(MathF.Min(ra.MaxX, rb.MaxX), MathF.Min(ra.MaxY, rb.MaxY)));
            }
            else
            {
                return new PointSet([]);
            }
        }

        public static IShape RectangleAndCircle(Rectangle a, Circle b)
        {
            return new PointSet(a.Discretize().Intersect(b.Discretize()).ToHashSet());
        }
    }

    public record struct And(IEnumerable<IShape> Shapes) : IShape
    {
        public readonly IShape Intersect(IShape other)
        {
            return new And(Shapes: Shapes.Select(s => s.Intersect(other)));
        }

        public HashSet<Vector2f> Discretize()
        {
            return Shapes.Select(s => s.Discretize()).Aggregate(new HashSet<Vector2f>(), 
                (all, h) => { all.UnionWith(h); return all; });
        }
    }

    public record struct PointSet(HashSet<Vector2f> Points) : IShape
    {
        public readonly IShape Intersect(IShape other)
        {
            if (other is PointSet ps)
            {
                return new PointSet(Points.Intersect(ps.Points).ToHashSet());
            }
            else
            {
                return other.Intersect(this);
            }
        }

        public HashSet<Vector2f> Discretize()
        {
            return Points;
        }
    }

    public record struct Line(Vector2f A, Vector2f B) : IShape
    {
        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndLine(this, line);
            else if (other is Circle circle) return ShapeIntersections.LineAndCircle(this, circle);
            else if (other is Rectangle rect) return ShapeIntersections.LineAndRectangle(this, rect);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }

        internal static HashSet<Vector2f> Bresenham(int x, int y, int x2, int y2)
        {
            HashSet<Vector2f> points = [];
            int w = x2 - x;
            int h = y2 - y;
            int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0;
            if (w < 0) dx1 = -1; else if (w > 0) dx1 = 1;
            if (h < 0) dy1 = -1; else if (h > 0) dy1 = 1;
            if (w < 0) dx2 = -1; else if (w > 0) dx2 = 1;
            int longest = Math.Abs(w);
            int shortest = Math.Abs(h);
            if (!(longest > shortest))
            {
                longest = Math.Abs(h);
                shortest = Math.Abs(w);
                if (h < 0) dy2 = -1; else if (h > 0) dy2 = 1;
                dx2 = 0;
            }
            int numerator = longest >> 1;
            for (int i = 0; i <= longest; i++)
            {
                points.Add(new Vector2f(x, y));
                numerator += shortest;
                if (!(numerator < longest))
                {
                    numerator -= longest;
                    x += dx1;
                    y += dy1;
                }
                else
                {
                    x += dx2;
                    y += dy2;
                }
            }

            return points;
        }
        public readonly HashSet<Vector2f> Discretize() => Bresenham((int)A.X, (int)A.Y, (int)B.X, (int)B.Y);
    }

    public record struct Circle(Vector2f Center, float Radius) : IShape
    {
        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndCircle(line, this);
            else if (other is Circle circle) return ShapeIntersections.CircleAndCircle(this, circle);
            else if (other is Rectangle rect) return ShapeIntersections.RectangleAndCircle(rect, this);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }

        internal static HashSet<Vector2f> CircleQuadLine(int xc, int yc, int x, int y)
        {
            return [
                new Vector2f(xc + x, yc + y),
                new Vector2f(xc - x, yc + y),
                new Vector2f(xc + x, yc - y),
                new Vector2f(xc - x, yc - y),
                new Vector2f(xc + y, yc + x),
                new Vector2f(xc - y, yc + x),
                new Vector2f(xc + y, yc - x),
                new Vector2f(xc - y, yc - x)
            ];
        }

        internal static HashSet<Vector2f> CircleQuadFill(int xc, int yc, int x, int y)
        {
            HashSet<Vector2f> points = [];
            for (int i = xc - x; i < xc + x; i++)
            {
                points.Add(new Vector2f(i, yc + y));
                points.Add(new Vector2f(i, yc - y));
            }
            for (int j = xc - y; j < xc + y; j++)
            {
                points.Add(new Vector2f(xc + x, j));
                points.Add(new Vector2f(xc - x, j));
            }
            return points;
        }

        static HashSet<Vector2f> CircleLine(int xc, int yc, int r)
        {
            int x = 0, y = r;
            int d = 3 - 2 * r;
            HashSet<Vector2f> points = [];
            points.UnionWith(CircleQuadLine(xc, yc, x, y));
            while (y >= x)
            {
                if (d > 0)
                {
                    y--;
                    d = d + 4 * (x - y) + 10;
                }
                else
                {
                    d = d + 4 * x + 6;
                }

                x++;
                points.UnionWith(CircleQuadLine(xc, yc, x, y));
            }

            return points;
        }

        internal static HashSet<Vector2f> CircleFill(int xc, int yc, int r)
        {
            int x = 0, y = r;
            int d = 3 - 2 * r;
            HashSet<Vector2f> points = [];
            points.UnionWith(CircleQuadFill(xc, yc, x, y));
            while (y >= x)
            {
                if (d > 0)
                {
                    y--;
                    d = d + 4 * (x - y) + 10;
                }
                else
                {
                    d = d + 4 * x + 6;
                }

                x++;
                points.UnionWith(CircleQuadFill(xc, yc, x, y));
            }

            return points;
        }

        public HashSet<Vector2f> Discretize()
        {
            return CircleLine((int)Center.X, (int)Center.Y, (int)Radius);
        }
    }

    public record struct Rectangle(Vector2f A, Vector2f B) : IShape
    {
        public float MinX => MathF.Min(A.X, B.X);
        public float MaxX => MathF.Max(A.X, B.X);
        public float MinY => MathF.Min(A.Y, B.Y);
        public float MaxY => MathF.Max(A.Y, B.Y);

        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndRectangle(line, this);
            else if (other is Circle circle) return ShapeIntersections.RectangleAndCircle(this, circle);
            else if (other is Rectangle rect) return ShapeIntersections.RectangleAndRectangle(this, rect);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }

        public HashSet<Vector2f> Discretize()
        {
            var tl = new Vector2f(MathF.Min(A.X, B.X), MathF.Min(A.Y, B.Y));
            var br = new Vector2f(MathF.Max(A.X, B.X), MathF.Max(A.Y, B.Y));
            var wh = new Vector2f(MathF.Abs(A.X - B.X), MathF.Abs(A.Y - B.Y));
            var l1 = new Line(tl, tl + new Vector2f(wh.X, 0));
            var l2 = new Line(tl, tl + new Vector2f(0, wh.Y));
            var l3 = new Line(br, br - new Vector2f(wh.X, 0));
            var l4 = new Line(br, br - new Vector2f(0, wh.Y));
            var points = new HashSet<Vector2f>();
            points.UnionWith(l1.Discretize());
            points.UnionWith(l2.Discretize());
            points.UnionWith(l3.Discretize());
            points.UnionWith(l4.Discretize());
            return points;
        }
    }

    public static class Geometry
    {
        public static PointSet Surface(IShape shape)
        {
            var p = new PointSet([]);
            if (shape is And and)
            {
                foreach (var item in and.Shapes)
                {
                    p.Points.UnionWith(Surface(item).Points);
                }
            }
            else if (shape is Line line)
            {
                p.Points.UnionWith(line.Discretize());
            }
            else if (shape is Circle circle)
            {
                p.Points.UnionWith(Circle.CircleFill((int)circle.Center.X, (int)circle.Center.Y, (int)circle.Radius));
            }
            else if (shape is Rectangle rect)
            {
                for (int i = (int)rect.MinX; i <= (int)rect.MaxX; i++)
                {
                    for (int j = (int)rect.MinY; i <= (int)rect.MaxY; j++)
                    {
                        p.Points.Add(new Vector2f(i, j));
                    }
                }
            }
            return p;
        }
    
        public static And Union(params IShape[] shapes)
        {
            return new And(shapes);
        }
    }
}
