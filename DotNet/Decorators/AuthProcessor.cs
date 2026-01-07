using System;

namespace DecoratorsDemo
{
    public static class AuthProcessor
    {
        public static void ProcessRequest(object controller, string methodName, string userRole)
        {
            var type = controller.GetType();
            var classAttr = Attribute.GetCustomAttribute(type, typeof(CustomAuthAttribute)) as CustomAuthAttribute;
            var method = type.GetMethod(methodName);
            var methodAttr = Attribute.GetCustomAttribute(method, typeof(CustomAuthAttribute)) as CustomAuthAttribute;

            string requiredRole = methodAttr?.Role ?? classAttr?.Role;
            if (requiredRole != null && requiredRole != userRole)
            {
                Console.WriteLine($"Access denied. Required role: {requiredRole}, but user role: {userRole}");
                return;
            }
            method.Invoke(controller, new object[] { userRole });
        }
    }
}
