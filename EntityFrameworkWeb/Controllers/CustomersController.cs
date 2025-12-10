using EntityFrameworkWeb.Data;
using EntityFrameworkWeb.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EntityFrameworkWeb.Controllers
{
    /// <summary>
    /// API Controller for managing customers
    /// Demonstrates various query patterns with Entity Framework
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class CustomersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<CustomersController> _logger;

        public CustomersController(ApplicationDbContext context, ILogger<CustomersController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// GET: api/customers
        /// Simple query - Gets all customers with optional pagination
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Customer>>> GetAllCustomers(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            _logger.LogInformation("Getting customers - Page: {Page}, PageSize: {PageSize}", page, pageSize);

            // Validate pagination parameters
            if (page < 1 || pageSize < 1 || pageSize > 100)
            {
                return BadRequest(new { message = "Invalid pagination parameters. Page must be >= 1, PageSize must be 1-100" });
            }

            // Query with pagination
            var totalCount = await _context.Customers.CountAsync();
            var customers = await _context.Customers
                .OrderBy(c => c.LastName)
                .ThenBy(c => c.FirstName)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new
            {
                page,
                pageSize,
                totalCount,
                totalPages = (int)Math.Ceiling(totalCount / (double)pageSize),
                customers
            });
        }

        /// <summary>
        /// GET: api/customers/5
        /// Route parameter - Gets a specific customer by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<Customer>> GetCustomer(int id)
        {
            _logger.LogInformation("Getting customer with ID: {CustomerId}", id);
            
            // Query with route parameter
            var customer = await _context.Customers.FindAsync(id);

            if (customer == null)
            {
                _logger.LogWarning("Customer with ID {CustomerId} not found", id);
                return NotFound(new { message = $"Customer with ID {id} not found" });
            }

            return Ok(customer);
        }

        /// <summary>
        /// GET: api/customers/by-email?email=john.doe@example.com
        /// Query string parameter - Gets a customer by email
        /// </summary>
        [HttpGet("by-email")]
        public async Task<ActionResult<Customer>> GetCustomerByEmail([FromQuery] string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return BadRequest(new { message = "Email parameter is required" });
            }

            _logger.LogInformation("Searching for customer by email: {Email}", email);
            
            // Query with query string parameter and case-insensitive comparison
            var customer = await _context.Customers
                .FirstOrDefaultAsync(c => c.Email.ToLower() == email.ToLower());

            if (customer == null)
            {
                return NotFound(new { message = $"Customer with email '{email}' not found" });
            }

            return Ok(customer);
        }

        /// <summary>
        /// GET: api/customers/search?query=john
        /// Query parameter - Searches customers by name or email (partial match)
        /// </summary>
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Customer>>> SearchCustomers([FromQuery] string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return BadRequest(new { message = "Search query is required" });
            }

            _logger.LogInformation("Searching customers with query: {Query}", query);
            
            // Query with multiple OR conditions and partial matching
            var searchTerm = query.ToLower();
            var customers = await _context.Customers
                .Where(c => c.FirstName.ToLower().Contains(searchTerm) ||
                           c.LastName.ToLower().Contains(searchTerm) ||
                           c.Email.ToLower().Contains(searchTerm))
                .OrderBy(c => c.LastName)
                .ThenBy(c => c.FirstName)
                .ToListAsync();

            return Ok(new { query, count = customers.Count, customers });
        }

        /// <summary>
        /// GET: api/customers/registered-between?startDate=2024-01-01&endDate=2024-12-31
        /// Multiple query parameters - Gets customers registered in a date range
        /// </summary>
        [HttpGet("registered-between")]
        public async Task<ActionResult<IEnumerable<Customer>>> GetCustomersRegisteredBetween(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate)
        {
            // Default to last 30 days if no dates provided
            startDate ??= DateTime.Now.AddDays(-30);
            endDate ??= DateTime.Now;

            if (startDate > endDate)
            {
                return BadRequest(new { message = "Start date cannot be after end date" });
            }

            _logger.LogInformation(
                "Getting customers registered between {StartDate} and {EndDate}",
                startDate, endDate);
            
            // Query with date range filtering
            var customers = await _context.Customers
                .Where(c => c.RegisteredAt >= startDate && c.RegisteredAt <= endDate)
                .OrderByDescending(c => c.RegisteredAt)
                .ToListAsync();

            return Ok(new
            {
                dateRange = new { startDate, endDate },
                count = customers.Count,
                customers
            });
        }

        /// <summary>
        /// GET: api/customers/with-phone
        /// Simple query with filtering - Gets customers who have a phone number
        /// </summary>
        [HttpGet("with-phone")]
        public async Task<ActionResult<IEnumerable<Customer>>> GetCustomersWithPhone()
        {
            _logger.LogInformation("Getting customers with phone numbers");
            
            // Query filtering for non-null values
            var customers = await _context.Customers
                .Where(c => c.Phone != null && c.Phone != "")
                .OrderBy(c => c.LastName)
                .ToListAsync();

            return Ok(new { count = customers.Count, customers });
        }

        /// <summary>
        /// GET: api/customers/by-lastname/Smith
        /// Route parameter - Gets all customers with a specific last name
        /// </summary>
        [HttpGet("by-lastname/{lastName}")]
        public async Task<ActionResult<IEnumerable<Customer>>> GetCustomersByLastName(string lastName)
        {
            _logger.LogInformation("Getting customers with last name: {LastName}", lastName);
            
            // Query with route parameter and case-insensitive comparison
            var customers = await _context.Customers
                .Where(c => c.LastName.ToLower() == lastName.ToLower())
                .OrderBy(c => c.FirstName)
                .ToListAsync();

            return Ok(new { lastName, count = customers.Count, customers });
        }

        /// <summary>
        /// GET: api/customers/recent?days=7
        /// Query parameter with default - Gets recently registered customers
        /// </summary>
        [HttpGet("recent")]
        public async Task<ActionResult<IEnumerable<Customer>>> GetRecentCustomers([FromQuery] int days = 30)
        {
            if (days < 1 || days > 365)
            {
                return BadRequest(new { message = "Days must be between 1 and 365" });
            }

            _logger.LogInformation("Getting customers registered in the last {Days} days", days);
            
            // Query with date calculation
            var cutoffDate = DateTime.Now.AddDays(-days);
            var customers = await _context.Customers
                .Where(c => c.RegisteredAt >= cutoffDate)
                .OrderByDescending(c => c.RegisteredAt)
                .ToListAsync();

            return Ok(new { days, cutoffDate, count = customers.Count, customers });
        }

        /// <summary>
        /// GET: api/customers/lastname/Smith/filter?registeredAfter=2024-01-01&hasPhone=true&sortBy=firstname
        /// Route parameter + Query parameters - Gets customers by last name with additional filters
        /// Demonstrates combining route parameters with query string parameters
        /// </summary>
        [HttpGet("lastname/{lastName}/filter")]
        public async Task<ActionResult<IEnumerable<Customer>>> GetCustomersByLastNameWithFilters(
            string lastName,
            [FromQuery] DateTime? registeredAfter,
            [FromQuery] DateTime? registeredBefore,
            [FromQuery] bool? hasPhone,
            [FromQuery] string? sortBy)
        {
            _logger.LogInformation(
                "Getting customers with last name '{LastName}' with filters - RegisteredAfter: {After}, RegisteredBefore: {Before}, HasPhone: {HasPhone}, SortBy: {SortBy}",
                lastName, registeredAfter, registeredBefore, hasPhone, sortBy);
            
            // Start with last name filter from route parameter
            IQueryable<Customer> query = _context.Customers
                .Where(c => c.LastName.ToLower() == lastName.ToLower());

            // Apply additional filters from query parameters
            if (registeredAfter.HasValue)
            {
                query = query.Where(c => c.RegisteredAt >= registeredAfter.Value);
            }

            if (registeredBefore.HasValue)
            {
                query = query.Where(c => c.RegisteredAt <= registeredBefore.Value);
            }

            if (hasPhone.HasValue)
            {
                if (hasPhone.Value)
                {
                    query = query.Where(c => c.Phone != null && c.Phone != "");
                }
                else
                {
                    query = query.Where(c => c.Phone == null || c.Phone == "");
                }
            }

            // Apply sorting based on query parameter
            query = sortBy?.ToLower() switch
            {
                "firstname" => query.OrderBy(c => c.FirstName),
                "firstname_desc" => query.OrderByDescending(c => c.FirstName),
                "email" => query.OrderBy(c => c.Email),
                "registered" => query.OrderBy(c => c.RegisteredAt),
                "registered_desc" => query.OrderByDescending(c => c.RegisteredAt),
                _ => query.OrderBy(c => c.FirstName) // Default sorting
            };

            var customers = await query.ToListAsync();

            return Ok(new
            {
                lastName,
                filters = new { registeredAfter, registeredBefore, hasPhone, sortBy },
                count = customers.Count,
                customers
            });
        }

        /// <summary>
        /// GET: api/customers/statistics
        /// Aggregation query - Gets customer statistics
        /// </summary>
        [HttpGet("statistics")]
        public async Task<ActionResult> GetCustomerStatistics()
        {
            _logger.LogInformation("Calculating customer statistics");
            
            // Various aggregation queries
            var totalCustomers = await _context.Customers.CountAsync();
            var customersWithPhone = await _context.Customers.CountAsync(c => c.Phone != null && c.Phone != "");
            var recentCustomers = await _context.Customers
                .CountAsync(c => c.RegisteredAt >= DateTime.Now.AddDays(-30));

            // Get registration trend by month (last 6 months)
            var sixMonthsAgo = DateTime.Now.AddMonths(-6);
            var registrationTrend = await _context.Customers
                .Where(c => c.RegisteredAt >= sixMonthsAgo)
                .GroupBy(c => new { Year = c.RegisteredAt.Year, Month = c.RegisteredAt.Month })
                .Select(g => new
                {
                    year = g.Key.Year,
                    month = g.Key.Month,
                    count = g.Count()
                })
                .OrderBy(x => x.year)
                .ThenBy(x => x.month)
                .ToListAsync();

            var stats = new
            {
                totalCustomers,
                customersWithPhone,
                customersWithoutPhone = totalCustomers - customersWithPhone,
                recentCustomers30Days = recentCustomers,
                registrationTrend
            };

            return Ok(stats);
        }

        /// <summary>
        /// POST: api/customers
        /// Creates a new customer
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<Customer>> CreateCustomer([FromBody] Customer customer)
        {
            _logger.LogInformation("Creating new customer: {FirstName} {LastName}", 
                customer.FirstName, customer.LastName);
            
            // Validate required fields
            if (string.IsNullOrWhiteSpace(customer.FirstName))
            {
                return BadRequest(new { message = "First name is required" });
            }

            if (string.IsNullOrWhiteSpace(customer.LastName))
            {
                return BadRequest(new { message = "Last name is required" });
            }

            if (string.IsNullOrWhiteSpace(customer.Email))
            {
                return BadRequest(new { message = "Email is required" });
            }

            // Check for duplicate email
            var existingCustomer = await _context.Customers
                .FirstOrDefaultAsync(c => c.Email.ToLower() == customer.Email.ToLower());

            if (existingCustomer != null)
            {
                return Conflict(new { message = "A customer with this email already exists" });
            }

            // Add new customer
            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Customer created with ID: {CustomerId}", customer.Id);

            return CreatedAtAction(nameof(GetCustomer), new { id = customer.Id }, customer);
        }

        /// <summary>
        /// PUT: api/customers/5
        /// Updates an existing customer
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCustomer(int id, [FromBody] Customer customer)
        {
            if (id != customer.Id)
            {
                return BadRequest(new { message = "ID mismatch" });
            }

            _logger.LogInformation("Updating customer with ID: {CustomerId}", id);

            var existingCustomer = await _context.Customers.FindAsync(id);
            if (existingCustomer == null)
            {
                return NotFound(new { message = $"Customer with ID {id} not found" });
            }

            // Check for email conflicts with other customers
            var emailConflict = await _context.Customers
                .AnyAsync(c => c.Id != id && c.Email.ToLower() == customer.Email.ToLower());

            if (emailConflict)
            {
                return Conflict(new { message = "Another customer with this email already exists" });
            }

            // Update properties
            existingCustomer.FirstName = customer.FirstName;
            existingCustomer.LastName = customer.LastName;
            existingCustomer.Email = customer.Email;
            existingCustomer.Phone = customer.Phone;

            try
            {
                await _context.SaveChangesAsync();
                _logger.LogInformation("Customer {CustomerId} updated successfully", id);
            }
            catch (DbUpdateConcurrencyException ex)
            {
                _logger.LogError(ex, "Concurrency error updating customer {CustomerId}", id);
                return Conflict(new { message = "Customer was modified by another user" });
            }

            return NoContent();
        }

        /// <summary>
        /// DELETE: api/customers/5
        /// Soft deletes a customer (sets IsDeleted flag)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            _logger.LogInformation("Deleting customer with ID: {CustomerId}", id);
            
            // Find customer including soft-deleted ones
            var customer = await _context.Customers
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(c => c.Id == id);

            if (customer == null)
            {
                return NotFound(new { message = $"Customer with ID {id} not found" });
            }

            // Soft delete by setting flag
            customer.IsDeleted = true;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Customer {CustomerId} soft deleted", id);

            return NoContent();
        }
    }
}
