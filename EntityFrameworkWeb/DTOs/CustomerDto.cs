namespace EntityFrameworkWeb.DTOs
{
    /// <summary>
    /// Data Transfer Object for creating a new customer
    /// </summary>
    public class CreateCustomerDto
    {
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
        /// Optional phone number
        /// </summary>
        public string? Phone { get; set; }
    }

    /// <summary>
    /// Data Transfer Object for updating a customer
    /// </summary>
    public class UpdateCustomerDto
    {
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
        /// Optional phone number
        /// </summary>
        public string? Phone { get; set; }
    }

    /// <summary>
    /// Data Transfer Object for customer response
    /// </summary>
    public class CustomerDto
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public string Email { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public DateTime RegisteredAt { get; set; }
    }
}
