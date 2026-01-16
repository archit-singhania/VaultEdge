# VaultEdge Architecture Documentation

## System Overview

VaultEdge is a real-time transaction authorization and risk-scoring platform designed for fintech-grade performance, security, and auditability. The system evaluates financial transactions in milliseconds and makes deterministic decisions (ALLOW, BLOCK, or REVIEW).

## High-Level Architecture

```
┌───────────────────────┐
│   Payment Apps        │  (Clients)
│   (POS, Web, Mobile)  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  Go Gateway           │  Port 8080
│  - Validation         │  (Transaction Ingestion)
│  - Rate Limiting      │
│  - Schema Check       │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  Rust Risk Engine     │  Port 8081
│  - Risk Scoring       │  (Core Decision Engine)
│  - Decision Logic     │
│  - Hot Path           │
└───────────┬───────────┘
            │
            ├──────────────────┐
            ▼                  ▼
┌───────────────────┐  ┌──────────────────┐
│  Haskell DSL      │  │  Assembly Crypto │
│  - Rule Engine    │  │  - Fast Hashing  │
│  - Pure Functions │  │  - Validation    │
└───────────────────┘  └──────────────────┘
            │
            ▼
┌───────────────────────┐
│  MongoDB              │
│  - Decisions          │  (Persistent Storage)
│  - Audit Logs         │
│  - Rules              │
└───────────┬───────────┘
            │
    ┌───────┴───────┐
    ▼               ▼
┌─────────────┐  ┌──────────────┐
│  .NET       │  │  Ruby        │
│  Control    │  │  Analyst     │
│  Plane      │  │  Tools       │
│  8082       │  │  4567        │
└─────────────┘  └──────────────┘
```

## Component Details

### 1. Go Gateway (Port 8080)
**Purpose**: First point of contact for all transactions

**Responsibilities**:
- Request validation (schema, signature)
- Rate limiting (1000 req/s, burst 1500)
- Request logging
- Load shedding under high traffic
- Forward to Risk Engine

**Tech Stack**: Go 1.21+, Gin framework, MongoDB driver

**Key Features**:
- Token bucket rate limiting
- HMAC signature validation
- JSON schema validation
- Timestamp verification

### 2. Rust Risk Engine (Port 8081)
**Purpose**: Core decision-making engine

**Responsibilities**:
- Calculate risk scores (0-100)
- Evaluate fraud rules
- Make ALLOW/BLOCK/REVIEW decisions
- Generate explanations
- Store decisions

**Tech Stack**: Rust 1.75+, Axum, MongoDB driver

**Performance Characteristics**:
- Sub-millisecond latency
- Memory-safe execution
- No GC pauses
- Predictable performance

**Risk Scoring Algorithm**:
```rust
Risk Score = Device Risk (30%) 
           + Amount Risk (30%)
           + Country Risk (20%)
           + Payment Method Risk (20%)
```

### 3. Haskell Rule DSL (Embedded)
**Purpose**: Pure functional rule evaluation

**Responsibilities**:
- Define fraud detection rules
- Deterministic evaluation
- Generate explanations
- Support rule versioning

**Tech Stack**: Haskell (Stack), Aeson

**Example Rule**:
```haskell
highRiskForeignRule = And
  (And (Amount > 100000)
       (Country != "US"))
  (DeviceRisk > 80)
```

### 4. Assembly Primitives (Embedded)
**Purpose**: Hot-path optimizations

**Responsibilities**:
- Fast hashing (FNV-1a)
- Token validation
- Constant-time comparison (security)

**Tech Stack**: x86-64 Assembly (NASM)

**Performance**: 10-100x faster than interpreted code

### 5. .NET Control Plane (Port 8082)
**Purpose**: Rule and audit management

**Responsibilities**:
- Rule CRUD operations
- Rule versioning
- Audit log storage and query
- Compliance reporting
- Decision history

**Tech Stack**: C# .NET 8.0, ASP.NET Core, MongoDB.Driver

**API Endpoints**:
- `GET /api/rules` - List all rules
- `POST /api/rules` - Create rule
- `GET /api/decisions` - Query decisions
- `GET /api/audit` - Audit logs
- `GET /api/compliance/report` - Compliance report

### 6. Ruby Analyst Tools (Port 4567)
**Purpose**: Human-friendly dashboards and DSL

**Responsibilities**:
- Transaction statistics dashboard
- High-risk transaction viewer
- Rule effectiveness analysis
- Natural language rule parser

**Tech Stack**: Ruby 3.0+, Sinatra, MongoDB

**DSL Example**:
```ruby
"block when amount > 100000 and country is not US"
```

### 7. Swift Mobile App
**Purpose**: Transaction review interface

**Responsibilities**:
- Display flagged transactions
- Show decision explanations
- Approve/deny manual reviews
- Offline support

**Tech Stack**: Swift 5, SwiftUI, Combine

## Data Flow

### Transaction Processing Flow

1. **Client** → POST to Gateway `/v1/transactions`
   ```json
   {
     "transaction": { ... },
     "signature": "hmac_sha256"
   }
   ```

2. **Gateway** validates:
   - Schema correctness
   - Signature authenticity
   - Timestamp freshness
   - Rate limit compliance

3. **Gateway** → Logs to MongoDB → Forwards to Risk Engine

4. **Risk Engine** calculates:
   - Base risk score
   - Rule evaluations (via Haskell)
   - Final decision

5. **Risk Engine** → Stores decision → Returns result

6. **Control Plane** provides query access

7. **Analyst Tools** aggregate statistics

### Decision Storage Schema

```json
{
  "_id": "ObjectId",
  "transactionId": "txn_123",
  "decision": "ALLOW|BLOCK|REVIEW",
  "riskScore": 45,
  "triggeredRules": ["rule_name"],
  "explanation": "...",
  "inputs": { transaction_data },
  "timestamp": "ISODate",
  "evaluationTimeMs": 2.3
}
```

## Performance Characteristics

### Latency Targets
- Gateway validation: < 1ms
- Risk scoring: < 2ms
- Rule evaluation: < 1ms
- Total processing: < 5ms (p99)

### Throughput
- Gateway: 1000 req/s sustained, 1500 burst
- Risk Engine: 2000+ evaluations/s
- MongoDB: 10,000+ writes/s

### Scalability
- Horizontal: Add more Risk Engine instances
- Vertical: Optimize hot paths with Assembly
- Database: MongoDB sharding for scale

## Security Model

### Request Authentication
- HMAC-SHA256 signatures
- Timestamp validation (5-minute window)
- Request replay prevention

### Audit Trail
Every action logged:
- Transaction evaluations
- Rule modifications
- Manual approvals/denials
- System events

### Compliance
Supports:
- PCI-DSS (Payment Card Industry)
- SOC2 Type II
- GDPR (data retention)
- Internal audits

## Deployment Architecture

### Development
```bash
./infra/setup.sh       # Install dependencies
./infra/start-all.sh   # Start services
./infra/test-integration.sh  # Run tests
```

### Production (Docker Compose)
```bash
docker-compose up -d
```

### Production (Kubernetes)
- See `/infra/k8s/` for manifests
- Helm charts available
- Auto-scaling configured

## Monitoring and Observability

### Metrics
- Transaction throughput
- Decision distribution (ALLOW/BLOCK/REVIEW)
- P50/P95/P99 latencies
- Error rates
- Rule trigger frequencies

### Logging
- Structured JSON logs
- Transaction correlation IDs
- Distributed tracing (OpenTelemetry)

### Alerting
- High error rates
- Latency spikes
- Rule misconfigurations
- MongoDB connection issues

## Technology Justification

### Why Rust?
- Memory safety without GC
- Predictable performance
- Excellent for hot paths
- Zero-cost abstractions

### Why Haskell?
- Pure functions = deterministic
- Strong typing = fewer bugs
- Referential transparency
- Formal reasoning

### Why Go?
- Simple concurrency
- Fast compilation
- Excellent for I/O
- Industry standard for gateways

### Why .NET?
- Enterprise trust
- Strong tooling
- Audit-friendly
- Compliance features

### Why Assembly?
- Maximum performance
- Shows hardware understanding
- Proves optimization skills
- Used sparingly (hot paths only)

## Future Enhancements

### Phase 2
- Machine learning risk models
- Real-time rule updates
- Multi-region deployment
- Advanced anomaly detection

### Phase 3
- Graph-based fraud detection
- Behavioral biometrics
- Kafka event streaming
- Real-time dashboards

## References

- [Go Best Practices](https://golang.org/doc/effective_go)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Haskell Guide](https://www.haskell.org/documentation/)
- [PCI-DSS Standards](https://www.pcisecuritystandards.org/)
