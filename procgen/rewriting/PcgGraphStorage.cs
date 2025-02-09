using NLua;

using SFML.System;

using svarog.runner;

using System.Xml.Linq;

using Universal.Common;
using Universal.Common.Collections;

namespace svarog.procgen.rewriting
{
    public class PcgGraphStorage
    {
        uint m_CurrentId = 0;

        private static int m_LastIncreased = 0;
        private static int m_Cycle = 0;
        public static int Cycle => m_Cycle;
        public static void ResetCycle() { m_Cycle = 0; }
        public static void ResetCycleLock() { m_LastIncreased = m_Cycle + 1; }
        public static void IncrCycle() { if (m_Cycle < m_LastIncreased) m_Cycle++; }

        public HashSet<uint> m_Nodes = new();
        MultiDictionary<uint, string> m_Annotated = new();
        HashSet<ulong> m_Connected = new();
        MultiDictionary<uint, uint> m_ArrowSources = new();
        MultiDictionary<uint, uint> m_ArrowTargets = new();
        MultiDictionary<ulong, uint> m_Arrows = new();
        Dictionary<uint, ulong> m_ArrowEndpoints = new();
        MultiDictionary<uint, string> m_NamedConnections = new();
        MultiDictionary<string, uint> m_NamedConnectionsByName = new();
        Dictionary<string, PcgTransform> m_Procedures = new();
        Dictionary<uint, int> m_Generations = new();

        public Dictionary<uint, Vector2f> Positions { get; private set; } = new();

        public Vector2f GetPosition(uint n)
        {
            return Positions[n];
        }

        public HashSet<uint> Nodes => m_Nodes;

        public static ulong CombineNodeIds(uint a, uint b) => (ulong)a << 32 | b;
        public static (uint, uint) ExtractNodeIds(ulong ab) => ((uint)(ab >> 32), (uint)ab);

        public void Clear()
        {
            ResetCycle();
            m_Nodes.Clear();
            m_Annotated.Clear();
            m_Connected.Clear();
            m_ArrowSources.Clear();
            m_ArrowTargets.Clear();
            m_Arrows.Clear();
            m_ArrowEndpoints.Clear();
            m_NamedConnections.Clear();
            m_NamedConnectionsByName.Clear();
            m_Procedures.Clear();
            m_Generations.Clear();
        }

        public bool HasAnnotation(uint n, string annotation) => m_Annotated.ContainsKey(n) && m_Annotated[n].Contains(annotation);
        public uint AddNode(string? annotation)
        {
            m_CurrentId++;
            m_Nodes.Add(m_CurrentId);

            if (annotation != null)
            {
                if (annotation.Contains("'"))
                {
                    IncrCycle();
                }

                if (!m_Generations.ContainsKey(m_CurrentId)) m_Generations.Add(m_CurrentId, Cycle);
                m_Annotated.Add(m_CurrentId, annotation);
            }
            return m_CurrentId;
        }

        public string? GetArrowName(uint arrow)
        {
            if (m_NamedConnections.ContainsKey(arrow))
            {
                if (m_NamedConnections[arrow].Count == 0)
                {
                    return null;
                }
                else
                {
                    return m_NamedConnections[arrow][0];
                }
            }
            return null;
        }

        public uint AddConn(uint a, uint b, string? name)
        {
            m_CurrentId++;
            ulong connId = CombineNodeIds(a, b);
            m_Connected.Add(connId);
            m_Arrows.Add(connId, m_CurrentId);
            m_ArrowEndpoints.Add(m_CurrentId, connId);
            m_ArrowSources.Add(a, m_CurrentId);
            m_ArrowTargets.Add(b, m_CurrentId);

            if (name != null)
            {
                m_NamedConnections.Add(m_CurrentId, name);
                m_NamedConnectionsByName.Add(name, m_CurrentId);
            }

            return m_CurrentId;
        }

        public bool HasConnBetween(uint a, uint b) =>
            m_Arrows.ContainsKey(CombineNodeIds(a, b));

        public HashSet<uint> GetConnsBetween(uint a, uint b)
        {
            var arrs = m_Arrows[CombineNodeIds(a, b)];
            return new HashSet<uint>(arrs);
        }

        public IEnumerable<string> GetNamesBetween(uint a, uint b)
        {
            return GetConnsBetween(a, b).Where(c => m_NamedConnections.ContainsKey(c)).SelectMany(c => m_NamedConnections[c]);
        }

        public void DeleteConn(uint c)
        {
            var connId = GetEndpoints(c);
            var (a, b) = ExtractNodeIds(connId);
            m_Connected.Remove(connId);
            m_Arrows.Remove(connId);
            m_ArrowEndpoints.Remove(c);
            m_ArrowSources[a].Remove(c);
            m_ArrowTargets[b].Remove(c);
            if (m_NamedConnections.ContainsKey(c))
            {
                foreach (var name in m_NamedConnections[c])
                {
                    m_NamedConnectionsByName.Remove(name);
                }
                m_NamedConnections.Remove(c);
            }
        }

        public ulong GetEndpoints(uint c)
        {
            return m_ArrowEndpoints[c];
        }

        public void RemoveConn(uint c)
        {
            if (m_ArrowEndpoints.TryGetValue(c, out ulong connId))
            {
                if (m_NamedConnections.ContainsKey(c))
                {
                    foreach (var n in m_NamedConnections[c])
                    {
                        m_NamedConnectionsByName[n].Remove(c);
                    }
                    m_NamedConnections.Remove(c);
                }
                m_Arrows[connId].Remove(c);
                var (a, b) = ExtractNodeIds(connId);
                m_ArrowSources[a].Remove(c);
                m_ArrowTargets[b].Remove(c);
                m_ArrowEndpoints.Remove(c);
            }
        }

        public void RemoveNode(uint n)
        {
            HashSet<uint> connections = [];
            foreach (uint c in m_ArrowSources[n])
            {
                connections.Add(c);
            }

            foreach (uint c in m_ArrowTargets[n])
            {
                connections.Add(c);
            }

            foreach (var c in connections) RemoveConn(c);
            m_Annotated.Remove(n);
            m_Nodes.Remove(n);
        }


        public int GetInDegree(uint n)
        {
            if (m_ArrowSources.ContainsKey(n))
            {
                return m_ArrowSources[n].Count;
            }

            return 0;
        }

        public int GetOutDegree(uint n)
        {
            if (m_ArrowTargets.ContainsKey(n))
            {
                return m_ArrowTargets[n].Count;
            }

            return 0;
        }

        public List<uint> GetArrowIdFromConnectionId(ulong connId)
        {
            return m_Arrows[connId];
        }

        public int CountArrowsCalled(string name)
        {
            if (m_NamedConnectionsByName.ContainsKey(name))
            {
                return m_NamedConnectionsByName[name].Count;
            }

            return 0;
        }

        public IEnumerable<uint> GetArrowsCalled(string name)
        {
            if (m_NamedConnectionsByName.ContainsKey(name))
            {
                foreach (var conn in m_NamedConnectionsByName[name])
                {
                    yield return conn;
                }
            }
        }

        public uint GetSource(uint arrow)
        {
            return ExtractNodeIds(m_ArrowEndpoints[arrow]).Item1;
        }

        public uint GetTarget(uint arrow)
        {
            return ExtractNodeIds(m_ArrowEndpoints[arrow]).Item2;
        }

        public IEnumerable<uint> GetArrowsFrom(uint n)
        {
            if (m_ArrowSources.ContainsKey(n))
            {
                foreach (var arr in m_ArrowSources[n])
                {
                    yield return arr;
                }
            }
        }

        public List<uint> ListArrowsFrom(uint n) => GetArrowsFrom(n).ToList();

        public IEnumerable<uint> GetArrowsTo(uint n)
        {
            if (m_ArrowTargets.ContainsKey(n))
            {
                foreach (var arr in m_ArrowTargets[n])
                {
                    yield return arr;
                }
            }
        }
        
        public List<uint> ListArrowsTo(uint n) => GetArrowsTo(n).ToList();

        public IEnumerable<uint> GetNeighbors(uint n)
        {
            foreach (var arr in GetArrowsFrom(n))
            {
                yield return GetTarget(arr);
            }
        }

        public List<uint> ListNeighbors(uint n) => GetNeighbors(n).ToList();

        public void ChangeArrowName(uint n, string newName)
        {
            if (m_NamedConnections.ContainsKey(n))
            {
                m_NamedConnections.Remove(n);
            }

            if (newName != null)
            {
                m_Generations.Add(m_CurrentId, Cycle);
                m_NamedConnections.Add(n, newName);
            }
        }

        public void AddAnnotation(uint n, string newAnn)
        {
            m_Annotated.Add(n, newAnn);
        }

        public string GetAnnotation(uint n)
        {
            if (m_Annotated.ContainsKey(n))
            {
                return $"{string.Join(" ", m_Annotated[n]).Replace("'", $"{m_Generations[n]}")}";
            }
            else
            {
                return "";
            }
        }

        public void ChangeAnnotation(uint n, string newAnn)
        {
            m_Annotated.Remove(n);
            m_Annotated.Add(n, newAnn);
        }

        public void RemoveAnnotation(uint n)
        {
            m_Annotated.Remove(n);
        }

        public PcgTransform? GetProc(string name) => m_Procedures[name];

        public void LoadProcs(string text)
        {
            PcgParseOutput? procs = new PcgParser().Parse(text);
            if (procs.HasValue)
            {
                foreach (var proc in procs.Value.procs)
                {
                    m_Procedures[proc.Name] = proc.Transform;
                }
            }
        }

        public string ToDot()
        {
            string Node(uint n) => $"{n}";

            var s = "";
            foreach (var arr in m_Arrows)
            {
                var (a, b) = ExtractNodeIds(arr.Key);
                s += $"{Node(a)} -> {Node(b)}";
                if (m_NamedConnections.ContainsKey(arr.Value))
                {
                    s += $" [ label = \"{string.Join(", ", m_NamedConnections[arr.Value])}\" ]";
                }
                s += "\n";
            }

            foreach (var node in m_Nodes)
            {
                var ann = GetAnnotation(node);
                s += $"{Node(node)} [ label = \"{ann}\" ]\n";
            }

            return s;
        }
    }
}
