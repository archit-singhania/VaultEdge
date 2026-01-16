using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using VaultEdge.ControlPlane.Models;
using VaultEdge.ControlPlane.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// MongoDB configuration
var mongoConnectionString = builder.Configuration.GetValue<string>("MongoDB:ConnectionString") 
    ?? "mongodb://localhost:27017";
var mongoDatabaseName = builder.Configuration.GetValue<string>("MongoDB:DatabaseName") 
    ?? "vaultedge";

builder.Services.AddSingleton<IMongoClient>(new MongoClient(mongoConnectionString));
builder.Services.AddSingleton<IMongoDatabase>(sp =>
{
    var client = sp.GetRequiredService<IMongoClient>();
    return client.GetDatabase(mongoDatabaseName);
});

// Register services
builder.Services.AddSingleton<AuditService>();
builder.Services.AddSingleton<RuleService>();
builder.Services.AddSingleton<DecisionService>();
builder.Services.AddSingleton<ComplianceService>();

// CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseHttpsRedirection();
app.UseAuthorization();

// Health check endpoint
app.MapGet("/health", () => new
{
    status = "UP",
    service = "VaultEdge Control Plane",
    version = "0.1.0",
    timestamp = DateTime.UtcNow
});

// Rule Management Endpoints
app.MapGet("/api/rules", async (RuleService ruleService) =>
{
    var rules = await ruleService.GetAllRulesAsync();
    return Results.Ok(rules);
});

app.MapGet("/api/rules/active", async (RuleService ruleService) =>
{
    var rules = await ruleService.GetActiveRulesAsync();
    return Results.Ok(rules);
});

app.MapGet("/api/rules/{id}", async (string id, RuleService ruleService) =>
{
    var rule = await ruleService.GetRuleByIdAsync(id);
    return rule is not null ? Results.Ok(rule) : Results.NotFound();
});

app.MapPost("/api/rules", async (Rule rule, RuleService ruleService) =>
{
    var createdRule = await ruleService.CreateRuleAsync(rule, "system");
    return Results.Created($"/api/rules/{createdRule.Id}", createdRule);
});

app.MapPut("/api/rules/{id}", async (string id, Rule rule, RuleService ruleService) =>
{
    var updatedRule = await ruleService.UpdateRuleAsync(id, rule, "system");
    return updatedRule is not null ? Results.Ok(updatedRule) : Results.NotFound();
});

app.MapDelete("/api/rules/{id}", async (string id, RuleService ruleService) =>
{
    var deleted = await ruleService.DeleteRuleAsync(id, "system");
    return deleted ? Results.NoContent() : Results.NotFound();
});

app.MapPatch("/api/rules/{id}/toggle", async (string id, [FromBody] bool isActive, RuleService ruleService) =>
{
    var toggled = await ruleService.ToggleRuleAsync(id, isActive, "system");
    return toggled ? Results.Ok() : Results.NotFound();
});

// Decision Query Endpoints
app.MapGet("/api/decisions", async (DecisionService decisionService, [FromQuery] int limit = 100) =>
{
    var decisions = await decisionService.GetDecisionsAsync(limit);
    return Results.Ok(decisions);
});

app.MapGet("/api/decisions/{transactionId}", async (string transactionId, DecisionService decisionService) =>
{
    var decision = await decisionService.GetDecisionByTransactionIdAsync(transactionId);
    return decision is not null ? Results.Ok(decision) : Results.NotFound();
});

// Audit Log Endpoints
app.MapGet("/api/audit", async (AuditService auditService, [FromQuery] int limit = 100) =>
{
    var logs = await auditService.GetAuditLogsAsync(limit);
    return Results.Ok(logs);
});

app.MapGet("/api/audit/user/{userId}", async (string userId, AuditService auditService, [FromQuery] int limit = 100) =>
{
    var logs = await auditService.GetAuditLogsByUserAsync(userId, limit);
    return Results.Ok(logs);
});

// Compliance Report Endpoint
app.MapGet("/api/compliance/report", async (
    [FromQuery] DateTime? startDate,
    [FromQuery] DateTime? endDate,
    ComplianceService complianceService) =>
{
    var start = startDate ?? DateTime.UtcNow.AddDays(-30);
    var end = endDate ?? DateTime.UtcNow;
    
    var report = await complianceService.GenerateReportAsync(start, end);
    return Results.Ok(report);
});

Console.WriteLine("🚀 VaultEdge Control Plane starting...");
app.Run();
