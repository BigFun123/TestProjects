namespace EntityFrameworkWeb.DTOs
{
    /// <summary>
    /// Data Transfer Object for creating a new product
    /// </summary>
    public class CreateProductDto
    {
        /// <summary>
        /// Name of the product
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Price of the product
        /// </summary>
        public decimal Price { get; set; }

        /// <summary>
        /// Initial stock quantity
        /// </summary>
        public int Stock { get; set; }

        /// <summary>
        /// Optional category for the product
        /// </summary>
        public string? Category { get; set; }
    }

    /// <summary>
    /// Data Transfer Object for updating a product
    /// </summary>
    public class UpdateProductDto
    {
        /// <summary>
        /// Name of the product
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Price of the product
        /// </summary>
        public decimal Price { get; set; }

        /// <summary>
        /// Quantity in stock
        /// </summary>
        public int Stock { get; set; }

        /// <summary>
        /// Optional category for the product
        /// </summary>
        public string? Category { get; set; }
    }

    /// <summary>
    /// Data Transfer Object for product response (excludes sensitive fields)
    /// </summary>
    public class ProductDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Stock { get; set; }
        public string? Category { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
