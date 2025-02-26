using svarog.runner;
using System.IO.Compression;

namespace svarog.utility.filesystem
{
    public class BinFileSystem : IFileSystem
    {
        private ZipArchive Archive;

        public BinFileSystem()
        {
            Archive = new ZipArchive(new FileStream("data.bin", FileMode.Open), ZipArchiveMode.Read);
        }
        public byte[] GetAsset(string name)
        {
            var entry = Archive.GetEntry(name);
            if (entry != null)
            {
                using (BinaryReader br = new BinaryReader(entry.Open()))
                {
                    return br.ReadBytes((int)entry.Length);
                }
            }
            return new byte[0];
        }

        public string GetFileContent(string name)
        {
            var entry = Archive.GetEntry(name);
            var content = "";
            if (entry != null)
            {
                using (StreamReader sr = new StreamReader(entry.Open()))
                {
                    content = sr.ReadToEnd();
                }
            }
            else
            {
                Svarog.Instance.LogError($"Could not find file: {name} in data.bin!");
            }

            return content;
        }

        public List<string> GetFiles(string path, string extension = "")
        {
            List<string> filteredFiles = new();

            foreach (var entry in Archive.Entries)
            {
                var s = entry.FullName.EndsWith(extension);
                var r = entry.FullName.StartsWith(path);
                if (s && r)
                {
                    filteredFiles.Add(entry.FullName);
                }
            }

            return filteredFiles;
        }
    }
}
