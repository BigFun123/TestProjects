namespace LinqDemo.Models;

/// <summary>
/// Represents an investor's portfolio
/// </summary>
public class Portfolio
{
    /// <summary>
    /// Unique identifier for the portfolio
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Portfolio name or account number
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Owner's name
    /// </summary>
    public string OwnerName { get; set; } = string.Empty;

    /// <summary>
    /// Date the portfolio was created
    /// </summary>
    public DateTime CreatedDate { get; set; }

    /// <summary>
    /// Total cash balance in the portfolio
    /// </summary>
    public decimal CashBalance { get; set; }

    /// <summary>
    /// Total market value of all holdings in the portfolio
    /// </summary>
    public decimal TotalValue { get; set; }

    /// <summary>
    /// Foreign key to Model
    /// </summary>
    public int ModelId { get; set; }

    /// <summary>
    /// Navigation property: The investment model used by this portfolio
    /// </summary>
    public Model Model { get; set; } = null!;

    /// <summary>
    /// Whether the portfolio is currently active
    /// </summary>
    public bool IsActive { get; set; } = true;
}
