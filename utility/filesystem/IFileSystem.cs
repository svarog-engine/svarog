namespace svarog.utility.filesystem
{
    public interface IFileSystem
    {
        public string GetFileContent(string name);
        public byte[] GetAsset(string name);
        List<string> GetFiles(string path, string extension = "");

        bool FileExists(string path);
    }
}