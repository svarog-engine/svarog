namespace svarog.utility.filesystem
{
    public class RawFileSystem : IFileSystem
    {
        public bool FileExists(string path)
        {
            return Path.Exists(path);
        }

        public byte[] GetAsset(string name)
        {
            return File.ReadAllBytes(name);
        }

        public string GetFileContent(string name)
        {
            return File.ReadAllText(name);
        }

        public List<string> GetFiles(string path, string extension = "")
        {
            List<string> filteredFiles = new();

            DirectoryInfo d = new DirectoryInfo(path);
            if (d.Exists)
            {
                FileInfo[] files = d.GetFiles("*" + extension);
                foreach (var file in files)
                {
                    filteredFiles.Add(file.FullName);
                }
            }

            return filteredFiles;
        }
    }
}
