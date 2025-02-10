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
            float dr = (float)Math.Sqrt(dx * dx + dy * dy);
            var d = a.A.X * a.B.Y - a.B.X * a.A.Y;
            var dis = b.Radius * b.Radius * dr * dr - d * d;

            var sdis = (float)Math.Sqrt(dis);
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
            var tl = new Vector2f((float)Math.Min(r.A.X, r.B.X), (float)Math.Min(r.A.Y, r.B.Y));
            var br = new Vector2f((float)Math.Max(r.A.X, r.B.X), (float)Math.Max(r.A.Y, r.B.Y));
            var wh = new Vector2f((float)Math.Abs(r.A.X - r.B.X), (float)Math.Abs(r.A.Y - r.B.Y));
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

        public static IShape LineAndSurface(Line a, Surface b)
        {
            return null;
        }

        public static IShape CircleAndCircle(Circle a, Circle b)
        {
            throw new NotImplementedException();
        }

        public static IShape RectangleAndRectangle(Rectangle a, Rectangle b)
        {
            throw new NotImplementedException();
        }

        public static IShape RectangleAndCircle(Rectangle a, Circle b)
        {
            throw new NotImplementedException();
        }

        public static IShape CircleAndRectangle(Circle a, Rectangle b)
        {
            throw new NotImplementedException();
        }

        public static IShape RectangeAndSurface(Rectangle a, Surface b)
        {
            throw new NotImplementedException();
        }
        public static IShape SurfaceAndSurface(Surface a, Surface b)
        {
            throw new NotImplementedException();
        }

        public static IShape CircleAndSurface(Circle a, Surface b)
        {
            throw new NotImplementedException();
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
            else if (other is Surface surface) return ShapeIntersections.LineAndSurface(this, surface);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }

        public HashSet<Vector2f> Discretize()
        {
            return [];
        }
    }

    public record struct Circle(Vector2f Center, float Radius) : IShape
    {
        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndCircle(line, this);
            else if (other is Circle circle) return ShapeIntersections.CircleAndCircle(this, circle);
            else if (other is Rectangle rect) return ShapeIntersections.CircleAndRectangle(this, rect);
            else if (other is Surface surface) return ShapeIntersections.CircleAndSurface(this, surface);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }

        public HashSet<Vector2f> Discretize()
        {
            return [];
        }
    }

    public record struct Rectangle(Vector2f A, Vector2f B) : IShape
    {
        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndRectangle(line, this);
            else if (other is Circle circle) return ShapeIntersections.RectangleAndCircle(this, circle);
            else if (other is Rectangle rect) return ShapeIntersections.RectangleAndRectangle(this, rect);
            else if (other is Surface surface) return ShapeIntersections.RectangeAndSurface(this, surface);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }
        public HashSet<Vector2f> Discretize()
        {
            return [];
        }
    }

    public record struct Surface(IShape Bound) : IShape
    {
        public IShape Intersect(IShape other)
        {
            if (other is Line line) return ShapeIntersections.LineAndSurface(line, this);
            else if (other is Circle circle) return ShapeIntersections.CircleAndSurface(circle, this);
            else if (other is Rectangle rect) return ShapeIntersections.RectangeAndSurface(rect, this);
            else if (other is Surface surface) return ShapeIntersections.SurfaceAndSurface(this, surface);
            else if (other is PointSet points) return new PointSet(this.Discretize().Intersect(points.Points).ToHashSet());
            else if (other is And conj) return conj.Intersect(this);

            return new PointSet([]);
        }
        public HashSet<Vector2f> Discretize()
        {
            return [];
        }
    }

}
