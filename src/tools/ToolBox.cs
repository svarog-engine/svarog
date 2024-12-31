using SFML.Graphics;

using svarog.src.windowing;
using System.Numerics;

namespace svarog.src.tools
{
    public interface IUndoableChange
    {
        public void Apply(ToolBox toolbox);
        public void Undo(ToolBox toolbox);
    }

    public struct GlyphBrush
    {
        public string Image { get; set; }
        public string Name { get; set; }
        public HashSet<Vector2> Blocks { get; set; }

        public Vector2 Min
        {
            get 
            {
                var x = Blocks.Select(b => b.X).Min();
                var y = Blocks.Select(b => b.Y).Min();
                return new Vector2(x, y);
            }
        }

        public Vector2 Max
        {
            get
            {
                var x = Blocks.Select(b => b.X).Max();
                var y = Blocks.Select(b => b.Y).Max();
                return new Vector2(x, y);
            }
        }

        public Vector2 Size => Max - Min + Vector2.One;

        public void ImGuiDraw(ToolBox toolBox, Vector2 xy, float scale)
        {
            //var texture = toolBox.ImguiTextures[Image];
            //var data = toolBox.FileData[Image];

            //var dg = (float)data.Type.GridSize();
            //var scaled = new Vector2(dg, dg) * scale;
            //var dw = dg / (float)texture.Width;
            //var dh = dg / (float)texture.Height;

            //var min = Min;
            //var max = Max;

            //for (int i = (int)min.X; i <= (int)max.X; i++)
            //{
            //    for (int j = (int)min.Y; j <= (int)max.Y; j++)
            //    {
            //        var block = new Vector2(i, j);
            //        var place = block - min;
            //        if (Blocks.Contains(block))
            //        {
            //            ImGui.SetCursorPos(xy + place * dg * scale);
            //            ImGui.Image(texture.GLTexture, scaled, new Vector2(i * dw, j * dh), new Vector2((i + 1) * dw, (j + 1) * dh));
            //        }
            //    }
            //}
        }
    }

    public class ToolBox : ITool
    {
        //private Dictionary<string, GLImGuiTexture> m_ImguiTextures = new();
        private Dictionary<string, Texture> m_Textures = new();
        private Dictionary<string, ITool> m_Tools = new();
        private HashSet<ITool> m_ToClose = new();
        private List<string> m_Files = new();
        private Dictionary<string, FileData> m_FileData = new();
        private Dictionary<string, List<GlyphBrush>> m_SavedBrushes = new();
        private Dictionary<string, Pattern> m_PatternsCached = new();
        public Vector3 CurrentPaint = Vector3.One;
        private PatternPreview m_PatternPreview;

        private Stack<IUndoableChange> m_ActionStack = new();
        private Stack<IUndoableChange> m_RedoStack = new();
        private Svarog m_Svarog;

        //internal Dictionary<string, GLImGuiTexture> ImguiTextures => m_ImguiTextures;
        internal Dictionary<string, Texture> Textures => m_Textures;

        public Dictionary<string, FileData> FileData => m_FileData;
        public List<string> Files => m_Files;

        public GlyphBrush? CurrentBrush { get; set; } = null;
        public string Name { get; set; }

        public ToolBox(Svarog svarog)
        {
            Name = "Toolbox";
            m_Svarog = svarog;

            m_PatternPreview = new PatternPreview(svarog);
        }

        public void Apply(IUndoableChange change)
        {
            if (m_RedoStack.Count > 0)
            {
                m_RedoStack.Clear();
            }
            m_ActionStack.Push(change);
            change.Apply(this);
        }

        public void Undo()
        {
            if (m_ActionStack.Count > 0)
            {
                var action = m_ActionStack.Pop();
                action.Undo(this);
                m_RedoStack.Push(action);
            }
        }

        public void Redo()
        {
            if (m_RedoStack.Count > 0)
            {
                var action = m_RedoStack.Pop();
                action.Apply(this);
                m_ActionStack.Push(action);
            }
        }

        public void RefreshFiles()
        {
            m_Files.Clear();

            var files = Directory.EnumerateFiles(".");
            foreach (var file in files)
            {
                if (file.EndsWith(".png"))
                {
                    m_Files.Add(file);

                    var data = new FileData();
                    data.Name = file;
                    data.Path = Path.GetFullPath(file);
                    var image = GetTexture(file);

                    if (file.EndsWith("_6x6.png"))
                    {
                        data.Type = EFileType.Spritesheet6x6;
                        data.Width = (int)(image.Size.X / 6);
                        data.Height = (int)(image.Size.Y / 6);
                    }
                    else if (file.EndsWith("_8x8.png"))
                    {
                        data.Type = EFileType.Spritesheet8x8;
                        data.Width = (int)(image.Size.X / 8);
                        data.Height = (int)(image.Size.Y / 8);
                    }
                    else if (file.EndsWith("_10x10.png"))
                    {
                        data.Type = EFileType.Spritesheet10x10;
                        data.Width = (int)(image.Size.X / 10);
                        data.Height = (int)(image.Size.Y / 10);
                    }
                    else if (file.EndsWith("_12x12.png"))
                    {
                        data.Type = EFileType.Spritesheet12x12;
                        data.Width = (int)(image.Size.X / 12);
                        data.Height = (int)(image.Size.Y / 12);
                    }
                    else if (file.EndsWith("_16x16.png"))
                    {
                        data.Type = EFileType.Spritesheet16x16;
                        data.Width = (int)(image.Size.X / 16);
                        data.Height = (int)(image.Size.Y / 16);
                    }
                    else
                    {
                        data.Type = EFileType.Image;
                        data.Width = (int)image.Size.X;
                        data.Height = (int)image.Size.Y;
                    }

                    m_FileData[file] = data;
                }
                else if (file.EndsWith(".pat"))
                {
                    m_Files.Add(file);
                    var data = new FileData();
                    data.Name = file;
                    data.Path = Path.GetFullPath(file);
                    data.Type = EFileType.Pattern;
                    var pat = File.ReadAllText(file).DeserializePattern();
                    data.Width = pat.Width;
                    data.Height = pat.Height;
                    m_FileData[file] = data;
                }
            }
        }

        internal Texture GetTexture(string name)
        {
            if (m_Textures.ContainsKey(name)) return m_Textures[name];

            var texture = new Texture(name, true);
            
            m_Textures[name] = texture;
            return texture;
        }

        //internal GLImGuiTexture GetImguiTexture(string name)
        //{
        //    if (m_ImguiTextures.ContainsKey(name)) return m_ImguiTextures[name];

        //    using var bitmap = new Bitmap(name);
        //    var texture = new GLImGuiTexture(name, bitmap, true, true);

        //    texture.SetMinFilter(OpenTK.Graphics.OpenGL4.TextureMinFilter.Nearest);
        //    texture.SetMagFilter(OpenTK.Graphics.OpenGL4.TextureMagFilter.Nearest);
        //    m_ImguiTextures[name] = texture;
        //    return texture;
        //}

        public void OpenImageSampler(FileData data)
        {
            if (!m_Tools.ContainsKey(data.Name))
            {
                m_Tools[data.Name] = new ImageSampler(m_Svarog, data.Name, data.Type.GridSize(), 2);
            }
        }

        public void OpenPatternEditor(string name)
        {
            if (!m_Tools.ContainsKey(name))
            {
                m_Tools[name] = new PatternEditor(m_Svarog, name);
            }
        }

        public void Render(IWindow window)
        {
            m_PatternPreview.Render(window);

            foreach (var tool in m_Tools)
            {
                tool.Value.Render(window);
            }

            foreach (var close in m_ToClose)
            {
                m_Tools.Remove(close.Name);
            }
            m_ToClose.Clear();
        }

        public void ShouldClose(ITool target)
        {
            m_ToClose.Add(target);
        }

        private int m_BrushCount = 0;

        public void AddNewBrush(string image, HashSet<Vector2> blocks)
        {
            if (!m_SavedBrushes.ContainsKey(image))
            {
                m_SavedBrushes[image] = new List<GlyphBrush>();
            }

            m_BrushCount++;
            m_SavedBrushes[image].Add(new GlyphBrush() { Image = image, Name = $"Stamp #{m_BrushCount}", Blocks = blocks });
        }

        public void AddBrush(GlyphBrush brush)
        {
            if (!m_SavedBrushes.ContainsKey(brush.Image))
            {
                m_SavedBrushes[brush.Image] = new List<GlyphBrush>();
            }

            m_SavedBrushes[brush.Image].Add(brush);
        }

        public IEnumerable<GlyphBrush> GetBrushes(string image)
        {
            if (m_SavedBrushes.ContainsKey(image))
            {
                foreach (var brush in m_SavedBrushes[image])
                {
                    yield return brush;
                }
            }
        }

        public GlyphBrush? GetBrush(string image, string key)
        {
            if (m_SavedBrushes.ContainsKey(image))
            {
                return m_SavedBrushes[image].Where(k => k.Name == key).First();
            }
            else
            {
                return null;
            }
        }

        public void UpdatePattern(string name, Pattern pat)
        {
            m_PatternsCached[name] = pat;
            File.WriteAllText($"{name}.pat", pat.Serialize());
        }

        public void UpdatePatternTileColor(string name, int id, Vector3 color)
        {
            if (m_PatternsCached.ContainsKey(name))
            {
                var pat = m_PatternsCached[name];
                foreach (var tile in pat.Data.Where(b => b.TargetId == id).ToArray())
                {
                    pat.Data.Remove(tile);
                    tile.Color = color;
                    pat.Data.Add(tile);
                }
                UpdatePattern(name, pat);
            }
        }

        public void UpdatePatternData(string name, PatternBlock[] blocks)
        {
            if (m_PatternsCached.ContainsKey(name))
            {
                var pat = m_PatternsCached[name];
                pat.Data = blocks.ToList();
                UpdatePattern(name, pat);
            }
        }
        public Pattern GetPattern(string name)
        {
            var n = name.Replace(".pat", "");
            if (m_PatternsCached.ContainsKey(n))
            {
                return m_PatternsCached[n];
            }
            else
            {
                var src = File.ReadAllText(name);
                var pat = src.DeserializePattern();
                m_PatternsCached[pat.Name] = pat;
                return m_PatternsCached[pat.Name];
            }
        }

        public void RemoveBrush(string image, string key)
        {
            if (m_SavedBrushes.ContainsKey(image))
            {
                m_SavedBrushes[image].RemoveAll(k => k.Name == key);
            }
        }
    
        public void ImGuiDraw(string image, Vector2 source, Vector2 xy, float scale, Vector3 color)
        {
            //var texture = GetImguiTexture(image);
            //var data = FileData[image];

            //var dg = (float)data.Type.GridSize();
            //var scaled = new Vector2(dg, dg) * scale;
            //var dw = dg / (float)texture.Width;
            //var dh = dg / (float)texture.Height;
            
            //ImGui.SetCursorPos(xy);
            //ImGui.Image(texture.GLTexture, scaled, new Vector2(source.X * dw, source.Y * dh), new Vector2((source.X + 1) * dw, (source.Y + 1) * dh), new Vector4(color, 1.0f));
        }
    }
}
