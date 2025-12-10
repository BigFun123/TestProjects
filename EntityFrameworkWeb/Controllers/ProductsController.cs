using EntityFrameworkWeb.Data;
using EntityFrameworkWeb.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EntityFrameworkWeb.Controllers
{
    /// <summary>
    /// API Controller for managing products
    /// Demonstrates various query patterns with Entity Framework
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ApplicationDbContext context, ILogger<ProductsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// GET: api/products
        /// Simple query - Gets all products
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Product>>> GetAllProducts()
        {
            _logger.LogInformation("Getting all products");
            
            // Simple query - retrieve all products
            var products = await _context.Products.ToListAsync();
            
            return Ok(products);
        }

        /// <summary>
        /// GET: api/products/5
        /// Route parameter - Gets a specific product by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<Product>> GetProduct(int id)
        {
            _logger.LogInformation("Getting product with ID: {ProductId}", id);
            
            // Query with route parameter - find by primary key
            var product = await _context.Products.FindAsync(id);

            if (product == null)
            {
                _logger.LogWarning("Product with ID {ProductId} not found", id);
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            return Ok(product);
        }

        /// <summary>
        /// GET: api/products/by-name?name=Laptop
        /// Query string parameter - Gets a product by name (case-insensitive)
        /// </summary>
        [HttpGet("by-name")]
        public async Task<ActionResult<Product>> GetProductByName([FromQuery] string name)
        {
            _logger.LogInformation("Searching for product by name: {ProductName}", name);
            
            // Query with query string parameter - filter with LINQ
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Name.ToLower() == name.ToLower());

            if (product == null)
            {
                return NotFound(new { message = $"Product with name '{name}' not found" });
            }

            return Ok(product);
        }

        /// <summary>
        /// GET: api/products/category/Electronics
        /// Route parameter - Gets all products in a specific category
        /// </summary>
        [HttpGet("category/{category}")]
        public async Task<ActionResult<IEnumerable<Product>>> GetProductsByCategory(string category)
        {
            _logger.LogInformation("Getting products in category: {Category}", category);
            
            // Query with route parameter and filtering
            var products = await _context.Products
                .Where(p => p.Category == category)
                .OrderBy(p => p.Name)
                .ToListAsync();

            return Ok(new { category, count = products.Count, products });
        }

        /// <summary>
        /// GET: api/products/search?minPrice=50&maxPrice=500&category=Electronics&inStock=true
        /// Multiple query parameters - Advanced filtering with multiple conditions
        /// </summary>
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Product>>> SearchProducts(
            [FromQuery] decimal? minPrice,
            [FromQuery] decimal? maxPrice,
            [FromQuery] string? category,
            [FromQuery] bool? inStock)
        {
            _logger.LogInformation(
                "Searching products with filters - MinPrice: {MinPrice}, MaxPrice: {MaxPrice}, Category: {Category}, InStock: {InStock}",
                minPrice, maxPrice, category, inStock);
            
            // Start with all products
            IQueryable<Product> query = _context.Products;

            // Apply filters dynamically based on provided parameters
            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            if (!string.IsNullOrEmpty(category))
            {
                query = query.Where(p => p.Category == category);
            }

            if (inStock.HasValue && inStock.Value)
            {
                query = query.Where(p => p.Stock > 0);
            }

            // Execute the query
            var products = await query
                .OrderBy(p => p.Price)
                .ToListAsync();

            return Ok(new 
            { 
                filters = new { minPrice, maxPrice, category, inStock },
                count = products.Count,
                products 
            });
        }

        /// <summary>
        /// GET: api/products/price-range?min=100&max=1000
        /// Query parameters with validation - Gets products within price range
        /// </summary>
        [HttpGet("price-range")]
        public async Task<ActionResult<IEnumerable<Product>>> GetProductsByPriceRange(
            [FromQuery] decimal min = 0,
            [FromQuery] decimal max = decimal.MaxValue)
        {
            // Validate parameters
            if (min < 0 || max < 0)
            {
                return BadRequest(new { message = "Price values must be non-negative" });
            }

            if (min > max)
            {
                return BadRequest(new { message = "Minimum price cannot be greater than maximum price" });
            }

            _logger.LogInformation("Getting products in price range: {Min} - {Max}", min, max);
            
            // Query with range filtering
            var products = await _context.Products
                .Where(p => p.Price >= min && p.Price <= max)
                .OrderBy(p => p.Price)
                .ToListAsync();

            return Ok(new { priceRange = new { min, max }, count = products.Count, products });
        }

        /// <summary>
        /// GET: api/products/low-stock?threshold=20
        /// Query parameter with default value - Gets products with low stock
        /// </summary>
        [HttpGet("low-stock")]
        public async Task<ActionResult<IEnumerable<Product>>> GetLowStockProducts([FromQuery] int threshold = 15)
        {
            _logger.LogInformation("Getting low stock products (threshold: {Threshold})", threshold);
            
            // Query with comparison operator
            var products = await _context.Products
                .Where(p => p.Stock <= threshold)
                .OrderBy(p => p.Stock)
                .ThenBy(p => p.Name)
                .ToListAsync();

            return Ok(new { threshold, count = products.Count, products });
        }

        /// <summary>
        /// GET: api/products/category/Electronics/filter?minPrice=50&maxPrice=500&minStock=10&sortBy=price
        /// Route parameter + Query parameters - Gets products in a category with additional filters
        /// Demonstrates combining route parameters with query string parameters
        /// </summary>
        [HttpGet("category/{category}/filter")]
        public async Task<ActionResult<IEnumerable<Product>>> GetProductsByCategoryWithFilters(
            string category,
            [FromQuery] decimal? minPrice,
            [FromQuery] decimal? maxPrice,
            [FromQuery] int? minStock,
            [FromQuery] string? sortBy)
        {
            _logger.LogInformation(
                "Getting products in category '{Category}' with filters - MinPrice: {MinPrice}, MaxPrice: {MaxPrice}, MinStock: {MinStock}, SortBy: {SortBy}",
                category, minPrice, maxPrice, minStock, sortBy);
            
            // Start with category filter from route parameter
            IQueryable<Product> query = _context.Products
                .Where(p => p.Category == category);

            // Apply additional filters from query parameters
            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            if (minStock.HasValue)
            {
                query = query.Where(p => p.Stock >= minStock.Value);
            }

            // Apply sorting based on query parameter
            query = sortBy?.ToLower() switch
            {
                "price" => query.OrderBy(p => p.Price),
                "price_desc" => query.OrderByDescending(p => p.Price),
                "stock" => query.OrderBy(p => p.Stock),
                "stock_desc" => query.OrderByDescending(p => p.Stock),
                "name" => query.OrderBy(p => p.Name),
                _ => query.OrderBy(p => p.Name) // Default sorting
            };

            var products = await query.ToListAsync();

            return Ok(new
            {
                category,
                filters = new { minPrice, maxPrice, minStock, sortBy },
                count = products.Count,
                products
            });
        }

        /// <summary>
        /// GET: api/products/statistics
        /// Aggregation query - Gets statistics about products
        /// </summary>
        [HttpGet("statistics")]
        public async Task<ActionResult> GetProductStatistics()
        {
            _logger.LogInformation("Calculating product statistics");
            
            // Aggregation queries
            var stats = new
            {
                totalProducts = await _context.Products.CountAsync(),
                averagePrice = await _context.Products.AverageAsync(p => p.Price),
                minPrice = await _context.Products.MinAsync(p => p.Price),
                maxPrice = await _context.Products.MaxAsync(p => p.Price),
                totalInventoryValue = await _context.Products.SumAsync(p => p.Price * p.Stock),
                categories = await _context.Products
                    .GroupBy(p => p.Category)
                    .Select(g => new { category = g.Key, count = g.Count() })
                    .ToListAsync()
            };

            return Ok(stats);
        }

        /// <summary>
        /// POST: api/products
        /// Creates a new product
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
        {
            _logger.LogInformation("Creating new product: {ProductName}", product.Name);
            
            // Validate input
            if (string.IsNullOrWhiteSpace(product.Name))
            {
                return BadRequest(new { message = "Product name is required" });
            }

            if (product.Price < 0)
            {
                return BadRequest(new { message = "Price cannot be negative" });
            }

            // Add new product
            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Product created with ID: {ProductId}", product.Id);

            // Return created product with location header
            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
        }

        /// <summary>
        /// PUT: api/products/5
        /// Updates an existing product
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] Product product)
        {
            if (id != product.Id)
            {
                return BadRequest(new { message = "ID mismatch" });
            }

            _logger.LogInformation("Updating product with ID: {ProductId}", id);

            // Check if product exists
            var existingProduct = await _context.Products.FindAsync(id);
            if (existingProduct == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            // Update properties
            existingProduct.Name = product.Name;
            existingProduct.Price = product.Price;
            existingProduct.Stock = product.Stock;
            existingProduct.Category = product.Category;

            try
            {
                await _context.SaveChangesAsync();
                _logger.LogInformation("Product {ProductId} updated successfully", id);
            }
            catch (DbUpdateConcurrencyException ex)
            {
                _logger.LogError(ex, "Concurrency error updating product {ProductId}", id);
                return Conflict(new { message = "Product was modified by another user" });
            }

            return NoContent();
        }

        /// <summary>
        /// DELETE: api/products/5
        /// Soft deletes a product (sets IsDeleted flag)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            _logger.LogInformation("Deleting product with ID: {ProductId}", id);
            
            // Find product including soft-deleted ones
            var product = await _context.Products
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            // Soft delete by setting flag
            product.IsDeleted = true;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Product {ProductId} soft deleted", id);

            return NoContent();
        }
    }
}
