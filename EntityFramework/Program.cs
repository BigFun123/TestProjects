using EntityFrameworkDemo.Data;
using EntityFrameworkDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EntityFrameworkDemo
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Entity Framework Core Demo Application");
            Console.WriteLine("=======================================\n");

            // Create database context
            using (var context = new ApplicationDbContext())
            {
                // Ensure database and schema are created
                Console.WriteLine("Creating database and tables if they don't exist...");
                
                try
                {
                    // Delete existing database to start fresh (optional - comment out if you want to keep data)
                    context.Database.EnsureDeleted();
                    
                    // Create database and all tables
                    context.Database.EnsureCreated();
                    Console.WriteLine("Database and tables created successfully!\n");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error creating database: {ex.Message}");
                    return;
                }

                // Demonstrate CRUD operations
                CreateSampleData(context);
                ReadData(context);
                UpdateData(context);
                DeleteData(context);
                
                Console.WriteLine("\nDemo completed successfully!");
            }
        }

        /// <summary>
        /// Creates sample products and customers in the database
        /// </summary>
        static void CreateSampleData(ApplicationDbContext context)
        {
            Console.WriteLine("--- CREATE Operations ---");

            // Check if data already exists
            if (context.Products.Any())
            {
                Console.WriteLine("Sample data already exists. Skipping creation.\n");
                return;
            }

            // Add sample products
            var products = new List<Product>
            {
                new Product { Name = "Laptop", Price = 999.99m, Stock = 10, Category = "Electronics" },
                new Product { Name = "Mouse", Price = 29.99m, Stock = 50, Category = "Electronics" },
                new Product { Name = "Desk Chair", Price = 199.99m, Stock = 15, Category = "Furniture" },
                new Product { Name = "Monitor", Price = 349.99m, Stock = 20, Category = "Electronics" }
            };

            context.Products.AddRange(products);

            // Add sample customers
            var customers = new List<Customer>
            {
                new Customer { FirstName = "John", LastName = "Doe", Email = "john.doe@example.com", Phone = "555-0100" },
                new Customer { FirstName = "Jane", LastName = "Smith", Email = "jane.smith@example.com", Phone = "555-0101" },
                new Customer { FirstName = "Bob", LastName = "Johnson", Email = "bob.johnson@example.com" }
            };

            context.Customers.AddRange(customers);

            // Save changes to database
            int recordsAdded = context.SaveChanges();            
            Console.WriteLine($"Added {recordsAdded} records to the database.\n");            
        }

        /// <summary>
        /// Reads and displays data from the database
        /// </summary>
        static void ReadData(ApplicationDbContext context)
        {
            Console.WriteLine("--- READ Operations ---");

            // Read all products
            Console.WriteLine("Products in database:");
            var products = context.Products.ToList();
            foreach (var product in products)
            {
                Console.WriteLine($"  - {product.Name}: ${product.Price} (Stock: {product.Stock}, Category: {product.Category})");
            }
            Console.WriteLine();

            // Read all customers
            Console.WriteLine("Customers in database:");
            var customers = context.Customers.ToList();
            foreach (var customer in customers)
            {
                Console.WriteLine($"  - {customer.FirstName} {customer.LastName}: {customer.Email}");
            }
            Console.WriteLine();

            // Filtered query example
            Console.WriteLine("Electronics products only:");
            var electronics = context.Products
                .Where(p => p.Category == "Electronics")
                .OrderBy(p => p.Price)
                .ToList();
            foreach (var product in electronics)
            {
                Console.WriteLine($"  - {product.Name}: ${product.Price}");
            }
            Console.WriteLine();

            var q = context.Customers.ToQueryString();
            Console.WriteLine($"Sample Query String: {q}\n");
        }

        /// <summary>
        /// Updates existing records in the database
        /// </summary>
        static void UpdateData(ApplicationDbContext context)
        {
            Console.WriteLine("--- UPDATE Operations ---");

            // Find a product to update
            var laptop = context.Products.FirstOrDefault(p => p.Name == "Laptop");
            if (laptop != null)
            {
                Console.WriteLine($"Updating '{laptop.Name}' price from ${laptop.Price} to $899.99");
                laptop.Price = 899.99m;
                laptop.Stock = 8; // Also update stock
                
                context.SaveChanges();
                Console.WriteLine("Update completed.\n");
            }
        }

        /// <summary>
        /// Soft deletes a record from the database (marks as deleted)
        /// </summary>
        static void DeleteData(ApplicationDbContext context)
        {
            Console.WriteLine("--- DELETE Operations (Soft Delete) ---");

            // Find a product to delete
            var mouse = context.Products.FirstOrDefault(p => p.Name == "Mouse");
            if (mouse != null)
            {
                Console.WriteLine($"Soft deleting product: {mouse.Name}");
                // Soft delete: mark as deleted instead of removing
                mouse.IsDeleted = true;
                context.SaveChanges();
                Console.WriteLine("Soft delete completed.\n");
            }

            // Verify deletion - global filter automatically excludes deleted records
            int remainingProducts = context.Products.Count();
            Console.WriteLine($"Active products in database: {remainingProducts}");
            
            // Show all products including deleted ones
            var allProducts = context.Products.IgnoreQueryFilters().ToList();
            var deletedCount = allProducts.Count(p => p.IsDeleted);
            Console.WriteLine($"Total products (including {deletedCount} deleted): {allProducts.Count}");
        }
    }
}
