namespace LinqDemo.Models;

/// <summary>
/// Represents a group of investment models (e.g., Conservative, Moderate, Aggressive)
/// </summary>
public class ModelGroup
{
    /// <summary>
    /// Unique identifier for the model group
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Name of the model group
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Description of the group's investment strategy
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Risk level (Low, Medium, High)
    /// </summary>
    public string RiskLevel { get; set; } = string.Empty;

    /// <summary>
    /// Navigation property: Models that belong to this group
    /// </summary>
    public ICollection<Model> Models { get; set; } = new List<Model>();
}
