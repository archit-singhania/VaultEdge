# VaultEdge API Documentation

## Overview

VaultEdge provides four primary API endpoints for different responsibilities:

1. **Gateway API** (Port 8080) - Transaction submission
2. **Risk Engine API** (Port 8081) - Direct evaluation
3. **Control Plane API** (Port 8082) - Management & audit
4. **Analyst Tools API** (Port 4567) - Analytics & DSL

---

## 1. Gateway API (Port 8080)

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "UP",
  "service": "VaultEdge Gateway",
  "version": "0.1.0"
}
```

### Submit Transaction

```http
POST /v1/transactions
Content-Type: application/json
```

**Request Body:**
```json
{
  "transaction": {
    "id": "txn_unique_123",
    "amount": 150000.00,
    "currency": "USD",
    "country": "US",
    "deviceRisk": 25,
    "timestamp": 1704672000,
    "merchantId": "merch_001",
    "customerId": "cust_001",
    "paymentMethod": "credit_card"
  },
  "signature": "your_hmac_signature"
}
```

**Field Descriptions:**
- `id` (string, required): Unique transaction identifier
- `amount` (number, required): Transaction amount > 0
- `currency` (string, required): 3-letter currency code
- `country` (string, required): 2-letter country code
- `deviceRisk` (integer, required): Risk score 0-100
- `timestamp` (integer, required): Unix timestamp
- `merchantId` (string, required): Merchant identifier
- `customerId` (string, required): Customer identifier
- `paymentMethod` (string, required): Payment method type
- `signature` (string, required): HMAC-SHA256 signature

**Response (202 Accepted):**
```json
{
  "requestId": "req_abc123",
  "status": "ACCEPTED",
  "message": "Transaction accepted for processing",
  "transactionId": "txn_unique_123"
}
```

**Error Responses:**

400 Bad Request:
```json
{
  "requestId": "req_abc123",
  "status": "ERROR",
  "message": "Invalid request format: amount must be greater than 0"
}
```

401 Unauthorized:
```json
{
  "requestId": "req_abc123",
  "status": "ERROR",
  "message": "Invalid signature"
}
```

429 Too Many Requests:
```json
{
  "requestId": "req_abc123",
  "status": "ERROR",
  "message": "Rate limit exceeded"
}
```

---

## 2. Risk Engine API (Port 8081)

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "UP",
  "service": "VaultEdge Risk Engine",
  "version": "0.1.0"
}
```

### Evaluate Transaction

```http
POST /v1/evaluate
Content-Type: application/json
```

**Request Body:**
```json
{
  "transaction": {
    "id": "txn_001",
    "amount": 120000.00,
    "currency": "USD",
    "country": "FR",
    "deviceRisk": 85,
    "timestamp": 1704672000,
    "merchantId": "merch_001",
    "customerId": "cust_001",
    "paymentMethod": "crypto"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "result": {
    "decision": "BLOCK",
    "riskScore": 92,
    "triggeredRules": [
      "high_risk_foreign",
      "high_value_crypto"
    ],
    "explanation": "Risk score: 92. High-value foreign transaction with elevated device risk detected; High-value cryptocurrency transaction",
    "inputs": { ... },
    "timestamp": 1704672000
  },
  "error": null
}
```

**Decision Types:**
- `ALLOW` - Transaction approved, low risk
- `BLOCK` - Transaction rejected, high risk
- `REVIEW` - Manual review required, medium risk

---

## 3. Control Plane API (Port 8082)

### Health Check

```http
GET /health
```

### Rule Management

#### List All Rules

```http
GET /api/rules
```

**Response:**
```json
[
  {
    "id": "rule_123",
    "ruleName": "high_risk_foreign",
    "description": "High-value foreign transaction",
    "expression": "amount > 100000 && country != US && deviceRisk > 80",
    "version": 1,
    "isActive": true,
    "createdAt": "2024-01-08T10:00:00Z",
    "updatedAt": "2024-01-08T10:00:00Z",
    "createdBy": "admin"
  }
]
```

#### Get Active Rules

```http
GET /api/rules/active
```

#### Get Rule by ID

```http
GET /api/rules/{id}
```

#### Create Rule

```http
POST /api/rules
Content-Type: application/json
```

**Request:**
```json
{
  "ruleName": "suspicious_velocity",
  "description": "Multiple high-value transactions",
  "expression": "amount > 25000 && deviceRisk > 50",
  "createdBy": "admin"
}
```

**Response (201 Created):**
```json
{
  "id": "rule_456",
  "ruleName": "suspicious_velocity",
  "version": 1,
  "isActive": true,
  "createdAt": "2024-01-08T11:00:00Z"
}
```

#### Update Rule

```http
PUT /api/rules/{id}
Content-Type: application/json
```

#### Delete Rule

```http
DELETE /api/rules/{id}
```

**Response:** 204 No Content

#### Toggle Rule

```http
PATCH /api/rules/{id}/toggle
Content-Type: application/json
```

**Request:**
```json
false
```

### Decision Queries

#### Get Recent Decisions

```http
GET /api/decisions?limit=100
```

**Response:**
```json
[
  {
    "id": "dec_789",
    "transactionId": "txn_001",
    "decisionType": "BLOCK",
    "riskScore": 92,
    "triggeredRules": ["high_risk_foreign"],
    "explanation": "...",
    "timestamp": "2024-01-08T12:00:00Z",
    "evaluationTimeMs": 2.3
  }
]
```

#### Get Decision by Transaction ID

```http
GET /api/decisions/{transactionId}
```

### Audit Logs

#### Get All Audit Logs

```http
GET /api/audit?limit=100
```

**Response:**
```json
[
  {
    "id": "audit_001",
    "action": "CREATE_RULE",
    "resource": "Rule",
    "resourceId": "rule_123",
    "userId": "admin",
    "timestamp": "2024-01-08T10:00:00Z",
    "ipAddress": "192.168.1.1"
  }
]
```

#### Get Audit Logs by User

```http
GET /api/audit/user/{userId}?limit=100
```

### Compliance

#### Generate Compliance Report

```http
GET /api/compliance/report?startDate=2024-01-01&endDate=2024-01-31
```

**Response:**
```json
{
  "reportId": "report_001",
  "generatedAt": "2024-01-08T12:00:00Z",
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-01-31T23:59:59Z",
  "totalTransactions": 10000,
  "allowedTransactions": 9500,
  "blockedTransactions": 400,
  "reviewTransactions": 100,
  "ruleStatistics": {
    "high_risk_foreign": 150,
    "critical_device_risk": 100
  }
}
```

---

## 4. Analyst Tools API (Port 4567)

### Health Check

```http
GET /health
```

### Dashboard Statistics

```http
GET /api/dashboard/stats?days=7
```

**Response:**
```json
{
  "total": 1500,
  "by_decision": {
    "ALLOW": 1200,
    "BLOCK": 250,
    "REVIEW": 50
  },
  "avg_risk_scores": {
    "ALLOW": 25.5,
    "BLOCK": 88.3,
    "REVIEW": 65.2
  }
}
```

### High-Risk Transactions

```http
GET /api/dashboard/high-risk?threshold=80&limit=20
```

**Response:**
```json
[
  {
    "transactionId": "txn_001",
    "riskScore": 92,
    "amount": 120000,
    "country": "FR",
    "decision": "BLOCK"
  }
]
```

### Rule Effectiveness

```http
GET /api/dashboard/rule-effectiveness?days=30
```

**Response:**
```json
[
  {
    "rule": "high_risk_foreign",
    "totalTriggers": 150,
    "blockedCount": 130,
    "blockRate": 86.67
  }
]
```

### Risk Trend Analysis

```http
GET /api/dashboard/risk-trend?days=7
```

**Response:**
```json
[
  {
    "date": "2024-01-08",
    "avgRiskScore": 45.2,
    "maxRiskScore": 95,
    "transactionCount": 200
  }
]
```

### DSL Parser

```http
POST /api/dsl/parse
Content-Type: application/json
```

**Request:**
```json
{
  "rule": "block when amount > 100000 and country is not US"
}
```

**Response:**
```json
{
  "action": "BLOCK",
  "conditions": [
    {
      "field": "amount",
      "operator": ">",
      "value": 100000
    },
    {
      "field": "country",
      "operator": "!=",
      "value": "US"
    }
  ],
  "originalText": "block when amount > 100000 and country is not US"
}
```

---

## Common Error Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created |
| 202 | Accepted - Request accepted for processing |
| 204 | No Content - Successful deletion |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid authentication |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

---

## Rate Limiting

The Gateway enforces rate limiting:
- **Sustained**: 1000 requests/second
- **Burst**: 1500 requests/second
- **Algorithm**: Token bucket

When exceeded, you'll receive a `429 Too Many Requests` response.

---

## Authentication (Production)

In production, all endpoints require authentication:

```http
Authorization: Bearer your_jwt_token
```

For the MVP, authentication is simplified for testing purposes.

---

## Testing with cURL

### Test Low-Risk Transaction
```bash
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_test_001",
      "amount": 50.00,
      "currency": "USD",
      "country": "US",
      "deviceRisk": 10,
      "timestamp": '$(date +%s)',
      "merchantId": "merch_001",
      "customerId": "cust_001",
      "paymentMethod": "credit_card"
    },
    "signature": "test_signature"
  }'
```

### Test High-Risk Transaction
```bash
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_test_high",
      "amount": 150000.00,
      "currency": "USD",
      "country": "RU",
      "deviceRisk": 95,
      "timestamp": '$(date +%s)',
      "merchantId": "merch_001",
      "customerId": "cust_001",
      "paymentMethod": "crypto"
    },
    "signature": "test_signature"
  }'
```

### Query Decisions
```bash
curl http://localhost:8082/api/decisions?limit=10
```

### Get Dashboard Stats
```bash
curl http://localhost:4567/api/dashboard/stats?days=7
```
