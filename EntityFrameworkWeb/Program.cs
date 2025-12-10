using EntityFrameworkWeb.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Configure Entity Framework with SQL Server
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Swagger/OpenAPI support for API documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { 
        Title = "Entity Framework Web API", 
        Version = "v1",
        Description = "A demonstration of Entity Framework Core with various query patterns"
    });
});

var app = builder.Build();

// Initialize database with sample data
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    
    // Create database if it doesn't exist
    context.Database.EnsureCreated();
    
    // Seed data if database is empty
    if (!context.Products.Any())
    {
        SeedData(context);
    }
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();

/// <summary>
/// Seeds the database with sample data for testing
/// </summary>
static void SeedData(ApplicationDbContext context)
{
    var products = new[]
    {
        new EntityFrameworkWeb.Models.Product { Name = "Laptop", Price = 999.99m, Stock = 10, Category = "Electronics" },
        new EntityFrameworkWeb.Models.Product { Name = "Mouse", Price = 29.99m, Stock = 50, Category = "Electronics" },
        new EntityFrameworkWeb.Models.Product { Name = "Keyboard", Price = 79.99m, Stock = 30, Category = "Electronics" },
        new EntityFrameworkWeb.Models.Product { Name = "Desk Chair", Price = 199.99m, Stock = 15, Category = "Furniture" },
        new EntityFrameworkWeb.Models.Product { Name = "Monitor", Price = 349.99m, Stock = 20, Category = "Electronics" },
        new EntityFrameworkWeb.Models.Product { Name = "Desk", Price = 299.99m, Stock = 8, Category = "Furniture" }
    };
    
    var customers = new[]
    {
        new EntityFrameworkWeb.Models.Customer { FirstName = "John", LastName = "Doe", Email = "john.doe@example.com", Phone = "555-0100" },
        new EntityFrameworkWeb.Models.Customer { FirstName = "Jane", LastName = "Smith", Email = "jane.smith@example.com", Phone = "555-0101" },
        new EntityFrameworkWeb.Models.Customer { FirstName = "Bob", LastName = "Johnson", Email = "bob.johnson@example.com", Phone = "555-0102" },
        new EntityFrameworkWeb.Models.Customer { FirstName = "Alice", LastName = "Williams", Email = "alice.williams@example.com" }
    };
    
    context.Products.AddRange(products);
    context.Customers.AddRange(customers);
    context.SaveChanges();
}
