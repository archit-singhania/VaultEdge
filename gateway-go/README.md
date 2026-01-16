# VaultEdge Gateway (Go)

## Overview
Transaction ingestion gateway that validates, rate-limits, and forwards transactions to the risk engine.

## Features
- Request validation and schema enforcement
- Rate limiting (1000 req/s with burst capacity)
- Signature verification
- MongoDB transaction logging
- Health check endpoint

## Setup

```bash
# Install dependencies
go mod download

# Run the gateway
go run main.go
```

## Environment Variables
- `MONGO_URI`: MongoDB connection string (default: mongodb://localhost:27017)
- `RISK_ENGINE_URL`: Rust risk engine URL (default: http://localhost:8081)
- `PORT`: Server port (default: 8080)

## API Endpoints

### POST /v1/transactions
Submit a transaction for evaluation.

**Request Body:**
```json
{
  "transaction": {
    "id": "txn_123456",
    "amount": 150000.00,
    "currency": "USD",
    "country": "US",
    "deviceRisk": 25,
    "timestamp": 1704672000,
    "merchantId": "merch_789",
    "customerId": "cust_456",
    "paymentMethod": "credit_card"
  },
  "signature": "sha256_signature_here"
}
```

### GET /health
Health check endpoint.

## Testing

```bash
# Test health endpoint
curl http://localhost:8080/health

# Submit test transaction
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_test_001",
      "amount": 100.00,
      "currency": "USD",
      "country": "US",
      "deviceRisk": 30,
      "timestamp": '$(date +%s)',
      "merchantId": "merch_test",
      "customerId": "cust_test",
      "paymentMethod": "credit_card"
    },
    "signature": "test_signature_123"
  }'
```
