using System.Numerics;
using System.Runtime.Serialization;

namespace svarog.src.tools
{
    [DataContract]
    public class PatternBlock
    {
        [DataMember]
        public int TargetId;
        [DataMember]
        public string Source;
        [DataMember]
        public int SourceId;
        [DataMember]
        public Vector3 Color;

        public PatternBlock(int targetId, string source, int sourceId)
        {
            TargetId = targetId;
            Source = source;
            SourceId = sourceId;
            Color = Vector3.One;
        }

        public override string ToString()
        {
            return $"{TargetId} <- {Source}.{SourceId} [{Color}]";
        }
    }

    [DataContract]
    public class Pattern
    {
        [DataMember]
        public string Name;
        [DataMember]
        public int Width;
        [DataMember]
        public int Height;
        [DataMember]
        public int GridSize;
        [DataMember]
        public List<PatternBlock> Data;

        public void Save()
        {
            File.WriteAllText($"{Name}.pat", this.Serialize());
        }

        Pattern(string name, int width, int height, int gridSize, List<PatternBlock> data)
        {
            Name = name;
            Width = width;
            Height = height;
            GridSize = gridSize;
            Data = data;
        }

        public static Pattern NewPattern(string name, int width, int height, int gridSize)
        {
            return new Pattern(name, width, height, gridSize, new());
        }
    }

    public static class PatternExt
    {
        public static string Serialize(this Pattern obj)
        {
            using (MemoryStream memoryStream = new MemoryStream())
            using (StreamReader reader = new StreamReader(memoryStream))
            {
                DataContractSerializer serializer = new DataContractSerializer(typeof(Pattern));
                serializer.WriteObject(memoryStream, obj);
                memoryStream.Position = 0;
                return reader.ReadToEnd();
            }
        }

        public static Pattern DeserializePattern(this string xml)
        {
            using (Stream stream = new MemoryStream())
            {
                byte[] data = System.Text.Encoding.UTF8.GetBytes(xml);
                stream.Write(data, 0, data.Length);
                stream.Position = 0;
                DataContractSerializer deserializer = new DataContractSerializer(typeof(Pattern));
                return (Pattern)deserializer.ReadObject(stream);
            }
        }
    }
}
