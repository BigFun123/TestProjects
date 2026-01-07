namespace LinqDemo.Models;

/// <summary>
/// Represents an investment model with a specific allocation strategy
/// </summary>
public class Model
{
    /// <summary>
    /// Unique identifier for the model
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Name of the model
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Description of the model's strategy
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Target allocation percentage for equities (0-100)
    /// </summary>
    public decimal EquityAllocation { get; set; }

    /// <summary>
    /// Target allocation percentage for fixed income (0-100)
    /// </summary>
    public decimal FixedIncomeAllocation { get; set; }

    /// <summary>
    /// Foreign key to ModelGroup
    /// </summary>
    public int ModelGroupId { get; set; }

    /// <summary>
    /// Navigation property: The group this model belongs to
    /// </summary>
    public ModelGroup ModelGroup { get; set; } = null!;

    /// <summary>
    /// Navigation property: Holdings (instrument allocations) in this model
    /// </summary>
    public ICollection<Holding> Holdings { get; set; } = new List<Holding>();

    /// <summary>
    /// Navigation property: Portfolios using this model
    /// </summary>
    public ICollection<Portfolio> Portfolios { get; set; } = new List<Portfolio>();
}
