# VaultEdge Analyst Tools (Ruby)

## Overview
Human-friendly dashboard and DSL tools for risk analysts. Built with Ruby for rapid iteration and readability.

## Features
- **Transaction Statistics**: Real-time dashboard data
- **Risk Trend Analysis**: Visualize risk patterns over time
- **Rule Effectiveness**: Measure which rules are most impactful
- **Natural Language DSL**: Write rules in plain English
- **High-Risk Alerts**: Monitor dangerous transactions

## Why Ruby?

1. **Readable**: Non-engineers can understand the code
2. **DSL-Friendly**: Perfect for natural language processing
3. **Rapid Development**: Fast iteration for analyst tools
4. **Community**: Rich ecosystem of gems

## Setup

```bash
# Install dependencies
bundle install

# Run the server
ruby app.rb

# Or use rerun for auto-reload during development
rerun ruby app.rb
```

## Environment Variables

- `MONGO_URI`: MongoDB connection string (default: mongodb://localhost:27017)
- `MONGO_DB`: Database name (default: vaultedge)
- `PORT`: Server port (default: 4567)

## API Endpoints

### Dashboard Statistics

**GET /api/dashboard/stats**
- Query params: `days` (default: 7)
- Returns transaction counts by decision type

Example:
```bash
curl "http://localhost:4567/api/dashboard/stats?days=30"
```

Response:
```json
{
  "total": 15420,
  "by_decision": {
    "ALLOW": 14250,
    "BLOCK": 890,
    "REVIEW": 280
  },
  "avg_risk_scores": {
    "ALLOW": 23.5,
    "BLOCK": 91.2,
    "REVIEW": 67.8
  }
}
```

### High-Risk Transactions

**GET /api/dashboard/high-risk**
- Query params: `threshold` (default: 80), `limit` (default: 20)

Example:
```bash
curl "http://localhost:4567/api/dashboard/high-risk?threshold=85&limit=10"
```

### Rule Effectiveness

**GET /api/dashboard/rule-effectiveness**
- Query params: `days` (default: 30)
- Shows which rules trigger most often and their block rate

Example:
```bash
curl "http://localhost:4567/api/dashboard/rule-effectiveness?days=30"
```

Response:
```json
[
  {
    "rule": "high_risk_foreign",
    "totalTriggers": 450,
    "blockedCount": 420,
    "blockRate": 93.3
  },
  {
    "rule": "critical_device_risk",
    "totalTriggers": 320,
    "blockedCount": 310,
    "blockRate": 96.9
  }
]
```

### Risk Trend Analysis

**GET /api/dashboard/risk-trend**
- Query params: `days` (default: 7)
- Daily aggregated risk metrics

### Natural Language Rule Parser

**POST /api/dsl/parse**
- Parse natural language rules into structured format

Example:
```bash
curl -X POST http://localhost:4567/api/dsl/parse \
  -H "Content-Type: application/json" \
  -d '{
    "rule": "block when amount > 100000 and country is not US"
  }'
```

Response:
```json
{
  "action": "BLOCK",
  "conditions": [
    {"field": "amount", "operator": ">", "value": 100000},
    {"field": "country", "operator": "!=", "value": "US"}
  ],
  "originalText": "block when amount > 100000 and country is not US"
}
```

## Natural Language DSL Examples

```ruby
# Simple rules
"block when amount > 100000"
"review when device risk > 80"
"allow when country is US"

# Compound rules
"block when amount > 100000 and country is not US"
"review when device risk > 70 and payment method is crypto"

# Complex rules
"block when amount > 50000 and country is not US and device risk > 80"
```

## Use Cases

### For Risk Analysts
- Monitor high-risk transactions in real-time
- Analyze rule effectiveness
- Identify trends and patterns
- Create new rules using natural language

### For Compliance Officers
- Generate statistics for audits
- Track rule performance over time
- Identify false positive patterns

### For Product Teams
- A/B test different rule sets
- Measure impact of rule changes
- Optimize for conversion vs security

## Integration

This service is designed to be used by:
1. Internal dashboards (React/Vue frontends)
2. Jupyter notebooks for data science
3. CLI tools for operations teams
4. Slack bots for alerts

## Example: Building a Dashboard

```javascript
// Fetch statistics for last 7 days
const stats = await fetch('http://localhost:4567/api/dashboard/stats?days=7')
  .then(r => r.json());

// Display blocked transactions percentage
const blockRate = (stats.by_decision.BLOCK / stats.total * 100).toFixed(2);
console.log(`Block rate: ${blockRate}%`);
```

## MongoDB Aggregation Pipeline

Ruby's MongoDB driver makes it easy to write complex aggregations:

```ruby
pipeline = [
  { '$match' => { 'riskScore' => { '$gte' => 80 } } },
  { '$group' => { '_id' => '$country', 'count' => { '$sum' => 1 } } },
  { '$sort' => { 'count' => -1 } }
]

results = $decisions.aggregate(pipeline).to_a
```
