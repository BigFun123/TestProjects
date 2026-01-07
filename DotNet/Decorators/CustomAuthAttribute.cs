using System;

namespace DecoratorsDemo
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class CustomAuthAttribute : Attribute
    {
        public string Role { get; }
        public CustomAuthAttribute(string role)
        {
            Role = role;
        }
    }
}
