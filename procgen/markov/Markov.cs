using svarog.runner;

using System.Xml.Linq;

public class Markov
{
    public byte[]? Nor(byte[] first, string model, int width, int height, int steps = 10000, int amount = 3)
    {
        byte[] second = Run(model, width, height, steps, amount)!;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                var index = j * height + i;
                second[index] = (byte)(((first[index] == 0) && (second[index] > 0)) ? 1 : 0);
            }
        }
        return second;
    }

    public byte[]? Or(byte[] first, string model, int width, int height, int steps = 10000, int amount = 3)
    {
        byte[] second = Run(model, width, height, steps, amount)!;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                var index = j * height + i;
                second[index] = (byte)(first[index] | second[index]);
            }
        }
        return second;
    }

    public byte[]? And(byte[] first, string model, int width, int height, int steps = 10000, int amount = 3)
    {
        byte[] second = Run(model, width, height, steps, amount)!;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                var index = j * height + i;
                second[index] = (byte)(first[index] & second[index]);
            }
        }
        return second;
    }

    public byte[]? Xor(byte[] first, string model, int width, int height, int steps = 10000, int amount = 3)
    {
        byte[] second = Run(model, width, height, steps, amount)!;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                var index = j * height + i;
                second[index] = (byte)(first[index] ^ second[index]);
            }
        }
        return second;
    }

    public byte[]? Run(string model, int width, int height, int steps = 10000, int amount = 3)
    {
        var meta = Svarog.Instance.Random;

        string name = model;
        int MX = width;
        int MY = height;
        int MZ = 1;

        string filename = $"resources/procgen/models/{name}.xml";
        XDocument modeldoc;
        try { modeldoc = XDocument.Load(filename, LoadOptions.SetLineInfo); }
        catch (Exception)
        {
            Console.WriteLine($"ERROR: couldn't open xml file {filename}");
            return null;
        }

        Interpreter interpreter = Interpreter.Load(modeldoc.Root!, MX, MY, MZ);
        if (interpreter == null)
        {
            Console.WriteLine("ERROR");
            return null;
        }

        string? seedString = null;
        int[] seeds = seedString?.Split(' ').Select(int.Parse).ToArray() ?? [];
          
        for (int k = 0; k < amount; k++)
        {
            int seed = seeds != null && k < seeds.Length ? seeds[k] : meta.Range(0, int.MaxValue);
            var (result, legend, FX, FY, FZ) = interpreter.Run(seed, steps, false).Last();
            
            if (k < amount - 1) continue;
            return result;
        }

        return null;
    }
}
