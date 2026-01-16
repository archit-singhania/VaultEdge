# VaultEdge Control Plane (.NET)

## Overview
Enterprise-grade control plane for managing rules, audit logs, and compliance reporting. Built with .NET 8 for reliability and enterprise trust.

## Features
- **Rule Management**: CRUD operations for fraud detection rules
- **Audit Logging**: Immutable audit trail for all operations
- **Decision Queries**: Retrieve and analyze transaction decisions
- **Compliance Reports**: Generate regulatory-compliant reports
- **Swagger UI**: Interactive API documentation

## Architecture

### Services
- `RuleService`: Rule lifecycle management with versioning
- `DecisionService`: Query transaction decisions
- `AuditService`: Immutable audit log storage
- `ComplianceService`: Generate compliance reports

### Data Models
- `Rule`: Fraud detection rule with versioning
- `Decision`: Transaction evaluation result
- `AuditLog`: System action audit entry
- `ComplianceReport`: Regulatory compliance report

## Setup

```bash
# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run the application
dotnet run
```

## Environment Configuration

Edit `appsettings.json`:
```json
{
  "MongoDB": {
    "ConnectionString": "mongodb://localhost:27017",
    "DatabaseName": "vaultedge"
  }
}
```

## API Endpoints

### Rule Management

**GET /api/rules** - Get all rules
**GET /api/rules/active** - Get active rules only
**GET /api/rules/{id}** - Get rule by ID
**POST /api/rules** - Create new rule
**PUT /api/rules/{id}** - Update rule
**DELETE /api/rules/{id}** - Delete rule
**PATCH /api/rules/{id}/toggle** - Enable/disable rule

### Decisions

**GET /api/decisions** - Get recent decisions
**GET /api/decisions/{transactionId}** - Get decision for transaction

### Audit

**GET /api/audit** - Get audit logs
**GET /api/audit/user/{userId}** - Get logs for specific user

### Compliance

**GET /api/compliance/report** - Generate compliance report
  - Query params: `startDate`, `endDate`

## Example: Create Rule

```bash
curl -X POST http://localhost:5000/api/rules \
  -H "Content-Type: application/json" \
  -d '{
    "ruleName": "test_rule",
    "description": "Test rule for demo",
    "expression": "amount > 10000 && country != US",
    "createdBy": "admin"
  }'
```

## Example: Generate Compliance Report

```bash
curl "http://localhost:5000/api/compliance/report?startDate=2024-01-01&endDate=2024-12-31"
```

Response:
```json
{
  "reportId": "uuid-here",
  "generatedAt": "2024-01-08T...",
  "totalTransactions": 15420,
  "allowedTransactions": 14250,
  "blockedTransactions": 890,
  "reviewTransactions": 280,
  "ruleStatistics": {
    "high_risk_foreign": 450,
    "critical_device_risk": 320,
    "high_value_crypto": 120
  }
}
```

## Swagger UI

Access interactive API documentation:
```
http://localhost:5000/swagger
```

## Security Features

- Immutable audit logs (append-only)
- Rule versioning for accountability
- User attribution for all operations
- Timestamp-based event tracking

## Compliance Support

- **PCI-DSS**: Audit trail and access control
- **SOC2**: System monitoring and logging
- **GDPR**: Data access and retention policies
- **FinCEN**: Transaction monitoring and reporting

## Why .NET?

1. **Enterprise Trust**: Widely adopted in financial institutions
2. **Strong Typing**: Compile-time safety
3. **Excellent Tooling**: Visual Studio, Rider
4. **Performance**: High-throughput API handling
5. **Security**: Built-in security features
