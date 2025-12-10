namespace EntityFrameworkWeb.Models
{
    /// <summary>
    /// Represents a product in the inventory
    /// </summary>
    public class Product
    {
        /// <summary>
        /// Primary key for the Product entity
        /// </summary>
        public int Id { get; set; }

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

        /// <summary>
        /// Date when the product was added to the system
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        /// <summary>
        /// Indicates whether the product is soft-deleted
        /// </summary>
        public bool IsDeleted { get; set; } = false;
    }
}
