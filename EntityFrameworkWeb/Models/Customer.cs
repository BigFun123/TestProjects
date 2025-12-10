namespace EntityFrameworkWeb.Models
{
    /// <summary>
    /// Represents a customer in the system
    /// </summary>
    public class Customer
    {
        /// <summary>
        /// Primary key for the Customer entity
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// First name of the customer
        /// </summary>
        public string FirstName { get; set; } = string.Empty;

        /// <summary>
        /// Last name of the customer
        /// </summary>
        public string LastName { get; set; } = string.Empty;

        /// <summary>
        /// Email address of the customer
        /// </summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// Phone number of the customer
        /// </summary>
        public string? Phone { get; set; }

        /// <summary>
        /// Date when the customer registered
        /// </summary>
        public DateTime RegisteredAt { get; set; } = DateTime.Now;

        /// <summary>
        /// Indicates whether the customer is soft-deleted
        /// </summary>
        public bool IsDeleted { get; set; } = false;
    }
}
