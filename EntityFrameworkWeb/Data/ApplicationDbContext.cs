using Microsoft.EntityFrameworkCore;
using EntityFrameworkWeb.Models;

namespace EntityFrameworkWeb.Data
{
    /// <summary>
    /// Database context class for Entity Framework Core
    /// Manages the database connection and entity configurations
    /// </summary>
    public class ApplicationDbContext : DbContext
    {
        /// <summary>
        /// DbSet for Product entities
        /// </summary>
        public DbSet<Product> Products { get; set; }

        /// <summary>
        /// DbSet for Customer entities
        /// </summary>
        public DbSet<Customer> Customers { get; set; }

        /// <summary>
        /// Constructor that accepts DbContextOptions for dependency injection
        /// </summary>
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        /// <summary>
        /// Configures entity models and relationships
        /// </summary>
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Price).HasPrecision(18, 2);
                entity.Property(e => e.Category).HasMaxLength(100);
                
                // Global query filter to exclude soft-deleted records
                entity.HasQueryFilter(e => !e.IsDeleted);
            });

            // Configure Customer entity
            modelBuilder.Entity<Customer>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
                entity.Property(e => e.Phone).HasMaxLength(20);
                
                // Global query filter to exclude soft-deleted records
                entity.HasQueryFilter(e => !e.IsDeleted);
            });
        }
    }
}
