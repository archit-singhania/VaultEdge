# VaultEdge Risk Engine (Rust)

## Overview
High-performance risk scoring and decision engine built in Rust for memory safety and predictable latency.

## Features
- Real-time risk scoring (single-digit millisecond latency)
- Deterministic decision logic (ALLOW/BLOCK/REVIEW)
- Rule-based evaluation with explainability
- MongoDB integration for audit logs
- Memory-safe concurrent processing

## Risk Scoring Factors
1. **Device Risk** (0-30 points): Based on device reputation score
2. **Amount Risk** (5-30 points): Transaction amount thresholds
3. **Foreign Country** (0-20 points): Cross-border transaction risk
4. **Payment Method** (1-25 points): Risk by payment type

## Decision Rules
- **ALLOW**: Risk score < 60, no critical rules triggered
- **REVIEW**: Risk score 60-84, or any rule triggered
- **BLOCK**: Risk score ≥ 85, or 2+ rules triggered

### Implemented Rules
1. `high_risk_foreign`: Amount > $100k + foreign country + device risk > 80
2. `critical_device_risk`: Device risk score > 90
3. `suspicious_amount_pattern`: Amount just under $100k threshold
4. `high_value_crypto`: Crypto payment > $50k

## Setup

```bash
# Build the project
cargo build --release

# Run tests
cargo test

# Run the server
cargo run
```

## Environment Variables
- `MONGO_URI`: MongoDB connection string (default: mongodb://localhost:27017)
- `PORT`: Server port (default: 8081)
- `HOME_COUNTRY`: Home country code for risk calculation (default: US)

## API Endpoints

### POST /v1/evaluate
Evaluate a transaction and return decision.

**Request:**
```json
{
  "transaction": {
    "id": "txn_123",
    "amount": 150000.00,
    "currency": "USD",
    "country": "FR",
    "deviceRisk": 85,
    "timestamp": 1704672000,
    "merchantId": "merch_789",
    "customerId": "cust_456",
    "paymentMethod": "credit_card"
  }
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "decision": "BLOCK",
    "riskScore": 92,
    "triggeredRules": ["high_risk_foreign"],
    "explanation": "Risk score: 92. High-value foreign transaction with elevated device risk detected",
    "inputs": { ... },
    "timestamp": 1704672123
  }
}
```

### GET /health
Health check endpoint.

## Performance
- Target latency: < 5ms per evaluation
- Memory safe: No garbage collection pauses
- Concurrent: Handles thousands of requests per second

## Testing

```bash
# Run unit tests
cargo test

# Test with curl
curl -X POST http://localhost:8081/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_test",
      "amount": 100.00,
      "currency": "USD",
      "country": "US",
      "deviceRisk": 20,
      "timestamp": '$(date +%s)',
      "merchantId": "merch_test",
      "customerId": "cust_test",
      "paymentMethod": "credit_card"
    }
  }'
```
