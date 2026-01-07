namespace LinqDemo.Models;

/// <summary>
/// Represents a financial instrument (e.g., stock, bond, ETF)
/// </summary>
public class Instrument
{
    /// <summary>
    /// Unique identifier for the instrument
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Ticker symbol (e.g., AAPL, MSFT, SPY)
    /// </summary>
    public string Symbol { get; set; } = string.Empty;

    /// <summary>
    /// Full name of the instrument
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Type of instrument (Stock, Bond, ETF, etc.)
    /// </summary>
    public string InstrumentType { get; set; } = string.Empty;

    /// <summary>
    /// Current market price per unit
    /// </summary>
    public decimal CurrentPrice { get; set; }

    /// <summary>
    /// Currency code (USD, EUR, etc.)
    /// </summary>
    public string Currency { get; set; } = "USD";

    /// <summary>
    /// Navigation property: Holdings that contain this instrument
    /// </summary>
    public ICollection<Holding> Holdings { get; set; } = new List<Holding>();
}
