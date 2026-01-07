namespace LinqDemo.Models;

/// <summary>
/// Represents a holding of an instrument within a model
/// This is a many-to-many relationship between Models and Instruments with additional data
/// </summary>
public class Holding
{
    /// <summary>
    /// Unique identifier for the holding
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Foreign key to Model
    /// </summary>
    public int ModelId { get; set; }

    /// <summary>
    /// Navigation property: The model this holding belongs to
    /// </summary>
    public Model Model { get; set; } = null!;

    /// <summary>
    /// Foreign key to Instrument
    /// </summary>
    public int InstrumentId { get; set; }

    /// <summary>
    /// Navigation property: The instrument being held
    /// </summary>
    public Instrument Instrument { get; set; } = null!;

    /// <summary>
    /// Number of shares/units held
    /// </summary>
    public decimal Quantity { get; set; }

    /// <summary>
    /// Target weight in the model (as a percentage, 0-100)
    /// </summary>
    public decimal TargetWeight { get; set; }

    /// <summary>
    /// Purchase price per unit
    /// </summary>
    public decimal CostBasis { get; set; }
}
