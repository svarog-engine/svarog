namespace svarog.utility.filesystem
{
    public interface IFileSystem
    {
        public string GetFileContent(string name);
        public byte[] GetAsset(string name);
        List<string> GetFiles(string path, string extension = "");

        Stream GetStream(string path);

        bool FileExists(string path);
    }
}