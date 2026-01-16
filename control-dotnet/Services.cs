using MongoDB.Driver;
using VaultEdge.ControlPlane.Models;

namespace VaultEdge.ControlPlane.Services;

public class RuleService
{
    private readonly IMongoCollection<Rule> _rules;
    private readonly AuditService _auditService;

    public RuleService(IMongoDatabase database, AuditService auditService)
    {
        _rules = database.GetCollection<Rule>("rules");
        _auditService = auditService;
    }

    public async Task<List<Rule>> GetAllRulesAsync()
    {
        return await _rules.Find(_ => true).ToListAsync();
    }

    public async Task<List<Rule>> GetActiveRulesAsync()
    {
        return await _rules.Find(r => r.IsActive).ToListAsync();
    }

    public async Task<Rule?> GetRuleByIdAsync(string id)
    {
        return await _rules.Find(r => r.Id == id).FirstOrDefaultAsync();
    }

    public async Task<Rule> CreateRuleAsync(Rule rule, string userId)
    {
        rule.CreatedAt = DateTime.UtcNow;
        rule.UpdatedAt = DateTime.UtcNow;
        rule.Version = 1;
        
        await _rules.InsertOneAsync(rule);
        
        await _auditService.LogAsync(new AuditLog
        {
            Action = "CREATE_RULE",
            Resource = "Rule",
            ResourceId = rule.Id,
            UserId = userId
        });
        
        return rule;
    }

    public async Task<Rule?> UpdateRuleAsync(string id, Rule updatedRule, string userId)
    {
        var existingRule = await GetRuleByIdAsync(id);
        if (existingRule == null)
            return null;

        updatedRule.Id = id;
        updatedRule.Version = existingRule.Version + 1;
        updatedRule.UpdatedAt = DateTime.UtcNow;
        updatedRule.CreatedAt = existingRule.CreatedAt;

        await _rules.ReplaceOneAsync(r => r.Id == id, updatedRule);
        
        await _auditService.LogAsync(new AuditLog
        {
            Action = "UPDATE_RULE",
            Resource = "Rule",
            ResourceId = id,
            UserId = userId
        });

        return updatedRule;
    }

    public async Task<bool> DeleteRuleAsync(string id, string userId)
    {
        var result = await _rules.DeleteOneAsync(r => r.Id == id);
        
        if (result.DeletedCount > 0)
        {
            await _auditService.LogAsync(new AuditLog
            {
                Action = "DELETE_RULE",
                Resource = "Rule",
                ResourceId = id,
                UserId = userId
            });
        }
        
        return result.DeletedCount > 0;
    }

    public async Task<bool> ToggleRuleAsync(string id, bool isActive, string userId)
    {
        var update = Builders<Rule>.Update
            .Set(r => r.IsActive, isActive)
            .Set(r => r.UpdatedAt, DateTime.UtcNow);
        
        var result = await _rules.UpdateOneAsync(r => r.Id == id, update);
        
        if (result.ModifiedCount > 0)
        {
            await _auditService.LogAsync(new AuditLog
            {
                Action = isActive ? "ENABLE_RULE" : "DISABLE_RULE",
                Resource = "Rule",
                ResourceId = id,
                UserId = userId
            });
        }
        
        return result.ModifiedCount > 0;
    }
}

public class DecisionService
{
    private readonly IMongoCollection<Decision> _decisions;

    public DecisionService(IMongoDatabase database)
    {
        _decisions = database.GetCollection<Decision>("decisions");
    }

    public async Task<List<Decision>> GetDecisionsAsync(int limit = 100)
    {
        return await _decisions
            .Find(_ => true)
            .SortByDescending(d => d.Timestamp)
            .Limit(limit)
            .ToListAsync();
    }

    public async Task<Decision?> GetDecisionByTransactionIdAsync(string transactionId)
    {
        return await _decisions
            .Find(d => d.TransactionId == transactionId)
            .FirstOrDefaultAsync();
    }

    public async Task<List<Decision>> GetDecisionsByDateRangeAsync(DateTime start, DateTime end)
    {
        return await _decisions
            .Find(d => d.Timestamp >= start && d.Timestamp <= end)
            .ToListAsync();
    }
}

public class AuditService
{
    private readonly IMongoCollection<AuditLog> _auditLogs;

    public AuditService(IMongoDatabase database)
    {
        _auditLogs = database.GetCollection<AuditLog>("audit_logs");
    }

    public async Task LogAsync(AuditLog log)
    {
        log.Timestamp = DateTime.UtcNow;
        await _auditLogs.InsertOneAsync(log);
    }

    public async Task<List<AuditLog>> GetAuditLogsAsync(int limit = 100)
    {
        return await _auditLogs
            .Find(_ => true)
            .SortByDescending(a => a.Timestamp)
            .Limit(limit)
            .ToListAsync();
    }

    public async Task<List<AuditLog>> GetAuditLogsByUserAsync(string userId, int limit = 100)
    {
        return await _auditLogs
            .Find(a => a.UserId == userId)
            .SortByDescending(a => a.Timestamp)
            .Limit(limit)
            .ToListAsync();
    }
}

public class ComplianceService
{
    private readonly DecisionService _decisionService;

    public ComplianceService(DecisionService decisionService)
    {
        _decisionService = decisionService;
    }

    public async Task<ComplianceReport> GenerateReportAsync(DateTime startDate, DateTime endDate)
    {
        var decisions = await _decisionService.GetDecisionsByDateRangeAsync(startDate, endDate);
        
        var report = new ComplianceReport
        {
            ReportId = Guid.NewGuid().ToString(),
            GeneratedAt = DateTime.UtcNow,
            StartDate = startDate,
            EndDate = endDate,
            TotalTransactions = decisions.Count,
            AllowedTransactions = decisions.Count(d => d.DecisionType == "ALLOW"),
            BlockedTransactions = decisions.Count(d => d.DecisionType == "BLOCK"),
            ReviewTransactions = decisions.Count(d => d.DecisionType == "REVIEW")
        };

        // Calculate rule statistics
        var ruleStats = new Dictionary<string, int>();
        foreach (var decision in decisions)
        {
            foreach (var rule in decision.TriggeredRules)
            {
                ruleStats[rule] = ruleStats.GetValueOrDefault(rule, 0) + 1;
            }
        }
        report.RuleStatistics = ruleStats;

        return report;
    }
}
