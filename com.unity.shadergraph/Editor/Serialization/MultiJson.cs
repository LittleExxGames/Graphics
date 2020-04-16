using System;
using UnityEngine;

namespace UnityEditor.ShaderGraph.Serialization
{
    static class MultiJson
    {
        public static T Deserialize<T>(string json) where T : JsonObject
        {
            var entries = MultiJsonInternal.Parse(json, typeof(T).FullName);
            return (T)MultiJsonInternal.Deserialize(entries, false);
        }

        public static T Deserialize<T>(string json, JsonObject referenceRoot) where T : JsonObject
        {
            var entries = MultiJsonInternal.Parse(json, typeof(T).FullName);
            MultiJsonInternal.PopulateValueMap(referenceRoot);
            return (T)MultiJsonInternal.Deserialize(entries, true);
        }

        public static string Serialize(JsonObject mainObject)
        {
            return MultiJsonInternal.Serialize(mainObject);
        }
    }
}
