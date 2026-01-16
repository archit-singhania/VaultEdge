using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace VaultEdge.ControlPlane.Models;

public class Rule
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }
    
    [BsonElement("ruleName")]
    public required string RuleName { get; set; }
    
    [BsonElement("description")]
    public required string Description { get; set; }
    
    [BsonElement("expression")]
    public required string Expression { get; set; }
    
    [BsonElement("version")]
    public int Version { get; set; }
    
    [BsonElement("isActive")]
    public bool IsActive { get; set; } = true;
    
    [BsonElement("createdAt")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    [BsonElement("updatedAt")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    [BsonElement("createdBy")]
    public required string CreatedBy { get; set; }
}

public class Decision
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }
    
    [BsonElement("transactionId")]
    public required string TransactionId { get; set; }
    
    [BsonElement("decision")]
    public required string DecisionType { get; set; } // ALLOW, BLOCK, REVIEW
    
    [BsonElement("riskScore")]
    public int RiskScore { get; set; }
    
    [BsonElement("triggeredRules")]
    public List<string> TriggeredRules { get; set; } = new();
    
    [BsonElement("explanation")]
    public required string Explanation { get; set; }
    
    [BsonElement("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    [BsonElement("evaluationTimeMs")]
    public double EvaluationTimeMs { get; set; }
}

public class AuditLog
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }
    
    [BsonElement("action")]
    public required string Action { get; set; }
    
    [BsonElement("resource")]
    public required string Resource { get; set; }
    
    [BsonElement("resourceId")]
    public string? ResourceId { get; set; }
    
    [BsonElement("userId")]
    public required string UserId { get; set; }
    
    [BsonElement("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    [BsonElement("details")]
    public BsonDocument? Details { get; set; }
    
    [BsonElement("ipAddress")]
    public string? IpAddress { get; set; }
}

public class ComplianceReport
{
    public required string ReportId { get; set; }
    public DateTime GeneratedAt { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int TotalTransactions { get; set; }
    public int AllowedTransactions { get; set; }
    public int BlockedTransactions { get; set; }
    public int ReviewTransactions { get; set; }
    public Dictionary<string, int> RuleStatistics { get; set; } = new();
}
