## Entity Framework Web API Demo

A simple ASP.NET Core 8 Web API demonstrating Entity Framework Core with various query patterns.

### Features

- **Entity Framework Core** with SQL Server LocalDB
- **RESTful API** with full CRUD operations
- **Swagger/OpenAPI** documentation
- **Various query patterns**:
  - Simple queries (get all)
  - Route parameters (get by ID)
  - Query string parameters (filtering, search)
  - Complex filtering with multiple parameters
  - Pagination
  - Aggregation and statistics
  - Soft deletes

### Project Structure

```
EntityFrameworkWeb/
├── Controllers/
│   ├── ProductsController.cs    # Product management endpoints
│   └── CustomersController.cs   # Customer management endpoints
├── Data/
│   └── ApplicationDbContext.cs  # EF Core DbContext
├── Models/
│   ├── Product.cs               # Product entity
│   └── Customer.cs              # Customer entity
├── DTOs/
│   ├── ProductDto.cs            # Product data transfer objects
│   └── CustomerDto.cs           # Customer data transfer objects
├── Program.cs                    # Application startup
└── appsettings.json             # Configuration

```

### Getting Started

1. **Restore dependencies**:
   ```cmd
   dotnet restore
   ```

2. **Run the application**:
   ```cmd
   dotnet run
   ```

3. **Open Swagger UI**:
   Navigate to `https://localhost:<port>/swagger` (port shown in console)

### API Endpoints

#### Products

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/by-name?name=Laptop` - Get product by name
- `GET /api/products/category/{category}` - Get products by category
- `GET /api/products/search?minPrice=50&maxPrice=500&category=Electronics` - Advanced search
- `GET /api/products/price-range?min=100&max=1000` - Get products in price range
- `GET /api/products/low-stock?threshold=20` - Get low stock products
- `GET /api/products/statistics` - Get product statistics
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product (soft delete)

#### Customers

- `GET /api/customers?page=1&pageSize=10` - Get all customers (paginated)
- `GET /api/customers/{id}` - Get customer by ID
- `GET /api/customers/by-email?email=john@example.com` - Get customer by email
- `GET /api/customers/search?query=john` - Search customers
- `GET /api/customers/registered-between?startDate=2024-01-01&endDate=2024-12-31` - Get customers by registration date
- `GET /api/customers/with-phone` - Get customers with phone numbers
- `GET /api/customers/by-lastname/{lastName}` - Get customers by last name
- `GET /api/customers/recent?days=7` - Get recently registered customers
- `GET /api/customers/statistics` - Get customer statistics
- `POST /api/customers` - Create new customer
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer (soft delete)

### Query Pattern Examples

#### Simple Query
```csharp
// GET /api/products
var products = await _context.Products.ToListAsync();
```

#### Route Parameter
```csharp
// GET /api/products/5
var product = await _context.Products.FindAsync(id);
```

#### Query String Parameter
```csharp
// GET /api/products/by-name?name=Laptop
var product = await _context.Products
    .FirstOrDefaultAsync(p => p.Name.ToLower() == name.ToLower());
```

#### Multiple Parameters with Dynamic Filtering
```csharp
// GET /api/products/search?minPrice=50&maxPrice=500&category=Electronics
IQueryable<Product> query = _context.Products;
if (minPrice.HasValue)
    query = query.Where(p => p.Price >= minPrice.Value);
if (!string.IsNullOrEmpty(category))
    query = query.Where(p => p.Category == category);
var products = await query.ToListAsync();
```

#### Pagination
```csharp
// GET /api/customers?page=1&pageSize=10
var customers = await _context.Customers
    .OrderBy(c => c.LastName)
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

#### Aggregation
```csharp
// GET /api/products/statistics
var stats = new {
    totalProducts = await _context.Products.CountAsync(),
    averagePrice = await _context.Products.AverageAsync(p => p.Price),
    maxPrice = await _context.Products.MaxAsync(p => p.Price)
};
```

### Database

- Uses SQL Server LocalDB (automatically installed with Visual Studio)
- Database name: `scratch`
- Connection string in `appsettings.json`
- Database is automatically created on first run
- Sample data is seeded automatically

### Technologies

- .NET 8
- Entity Framework Core 8
- SQL Server LocalDB
- Swagger/OpenAPI
- ASP.NET Core Web API
