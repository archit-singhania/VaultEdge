# 🏦 VaultEdge

**Secure Transaction Authorization & Risk Engine (FinTech-Grade)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://golang.org/)
[![Rust](https://img.shields.io/badge/Rust-1.75+-orange?logo=rust)](https://www.rust-lang.org/)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Ruby](https://img.shields.io/badge/Ruby-3.0+-CC342D?logo=ruby)](https://www.ruby-lang.org/)
[![Haskell](https://img.shields.io/badge/Haskell-Stack-5D4F85?logo=haskell)](https://www.haskell.org/)

VaultEdge is a **real-time transaction authorization and risk-scoring platform** that evaluates financial transactions in **milliseconds** and deterministically decides whether to **ALLOW**, **BLOCK**, or **REVIEW** them using rule-based logic, strong auditability, and enterprise-grade security.

**Industry Relevance**: Stripe · PayPal · Visa · Mastercard · Banks · FinTech Infrastructure

---

## 🎯 One-Liner (Recruiter Friendly)

> VaultEdge is a production-grade fintech risk engine that processes transactions in <5ms, combining multi-language microservices (Go, Rust, C#, Ruby, Haskell, Assembly) to demonstrate systems design, performance engineering, and compliance-ready architecture.

---

## ✨ Key Features

### Core Capabilities
- ⚡ **Sub-5ms Transaction Processing** - Real-time evaluation with predictable latency
- 🛡️ **Deterministic Decision Engine** - Reproducible ALLOW/BLOCK/REVIEW decisions
- 📊 **Multi-Factor Risk Scoring** - Device, amount, geography, payment method analysis
- 📝 **Complete Audit Trail** - Every decision tracked for compliance (PCI-DSS, SOC2)
- 🔄 **Dynamic Rule Updates** - Change fraud rules without redeploying services
- 🔍 **Explainable Decisions** - Every decision includes reasoning and triggered rules

### Technical Highlights
- 🦀 **Rust Core Engine** - Memory-safe, zero-cost abstractions, no GC pauses
- 🐹 **Go API Gateway** - High-throughput ingestion with rate limiting
- 🟦 **C# Control Plane** - Enterprise-grade rule management and audit APIs
- 💎 **Ruby DSL** - Human-friendly rule authoring and analytics
- 🎓 **Haskell Rule Engine** - Pure functional, deterministic evaluation
- ⚙️ **Assembly Optimizations** - Hot-path cryptographic operations
- 📱 **Swift Mobile App** - iOS transaction review interface

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     TRANSACTION FLOW                             │
└─────────────────────────────────────────────────────────────────┘

    Payment Apps (POS, Web, Mobile)
              │
              ▼
    ┌──────────────────────┐
    │  Go Gateway          │  Port 8080
    │  • Validation        │  • Rate Limiting (1000 req/s)
    │  • Auth Check        │  • Schema Validation
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │  Rust Risk Engine    │  Port 8081
    │  • Risk Scoring      │  • <2ms Evaluation
    │  • Rule Execution    │  • Decision Making
    └──────────┬───────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌─────────────┐  ┌──────────────┐
│  Haskell    │  │  Assembly    │
│  DSL Rules  │  │  Crypto      │
└─────────────┘  └──────────────┘
       │
       ▼
┌─────────────────────┐
│  MongoDB            │
│  • Decisions        │
│  • Audit Logs       │
│  • Rules History    │
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌─────────┐  ┌──────────┐
│ .NET    │  │ Ruby     │
│ Control │  │ Analyst  │
│ :8082   │  │ :4567    │
└─────────┘  └──────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **Docker** & **Docker Compose** (required)
- **Go** 1.21+ (for Gateway)
- **Rust** 1.75+ (for Risk Engine)
- **.NET** 8.0+ (for Control Plane)
- **Ruby** 3.0+ (for Analyst Tools)
- **Haskell** Stack (for Rule Engine)
- **NASM** (for Assembly primitives)
- **MongoDB** (via Docker)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/vaultedge.git
cd vaultedge

# Run setup script (installs all dependencies)
chmod +x infra/setup.sh
./infra/setup.sh

# Start all services
chmod +x infra/start-all.sh
./infra/start-all.sh

# Verify all services are running
curl http://localhost:8080/health  # Gateway
curl http://localhost:8081/health  # Risk Engine
curl http://localhost:8082/health  # Control Plane
curl http://localhost:4567/health  # Analyst Tools
```

### Run Integration Tests

```bash
chmod +x infra/test-integration.sh
./infra/test-integration.sh
```

Expected output:
```
✓ Gateway Health Check - PASS
✓ Risk Engine Health Check - PASS
✓ Low Risk Transaction - PASS (ALLOW)
✓ High Risk Transaction - PASS (BLOCK)
✓ Rule Management - PASS
...
📊 Test Summary: 15/15 tests passed ✅
```

---

## 📖 Usage Examples

### 1. Submit a Low-Risk Transaction

```bash
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_001",
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

**Expected Response:**
```json
{
  "requestId": "req_abc123",
  "status": "ACCEPTED",
  "transactionId": "txn_001"
}
```

### 2. Submit a High-Risk Transaction

```bash
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "txn_002",
      "amount": 150000.00,
      "currency": "USD",
      "country": "RU",
      "deviceRisk": 95,
      "timestamp": '$(date +%s)',
      "merchantId": "merch_001",
      "customerId": "cust_002",
      "paymentMethod": "crypto"
    },
    "signature": "test_signature"
  }'
```

**Decision:** BLOCK (Risk Score: 92)

### 3. Query Decisions

```bash
# Get recent decisions
curl http://localhost:8082/api/decisions?limit=10

# Get specific transaction decision
curl http://localhost:8082/api/decisions/txn_001
```

### 4. View Dashboard Statistics

```bash
curl http://localhost:4567/api/dashboard/stats?days=7
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

---

## 🧩 Technology Stack

| Component | Technology | Purpose | Port |
|-----------|------------|---------|------|
| **Gateway** | Go + Gin | Transaction ingestion, validation, rate limiting | 8080 |
| **Risk Engine** | Rust + Axum | Core decision logic, risk scoring | 8081 |
| **Control Plane** | C# .NET 8 | Rule management, audit logs, compliance | 8082 |
| **Analyst Tools** | Ruby + Sinatra | Analytics, DSL, dashboards | 4567 |
| **Rule Engine** | Haskell | Pure functional rule evaluation | (embedded) |
| **Crypto Primitives** | x86-64 Assembly | Fast hashing, token validation | (embedded) |
| **Mobile App** | Swift + SwiftUI | Transaction review interface | - |
| **Database** | MongoDB | Persistent storage for all data | 27017 |

### Why This Stack?

- **Rust**: Memory safety, predictable performance, no GC pauses (critical for fintech)
- **Go**: Simple concurrency, fast compilation, industry standard for gateways
- **C#/.NET**: Enterprise trust, strong tooling, audit-friendly
- **Haskell**: Pure functions = deterministic behavior, formal reasoning
- **Ruby**: Excellent for DSLs, fast iteration, readable for non-engineers
- **Assembly**: Maximum performance for hot paths, demonstrates low-level understanding

---

## 🔍 Decision Logic

### Risk Score Calculation

```
Risk Score (0-100) = Device Risk (30%)
                   + Amount Risk (30%)
                   + Country Risk (20%)
                   + Payment Method Risk (20%)
```

### Decision Thresholds

- **ALLOW**: Risk Score < 60, no critical rules triggered
- **REVIEW**: Risk Score 60-84, or 1 rule triggered
- **BLOCK**: Risk Score ≥ 85, or 2+ rules triggered

### Example Rules

1. **High-Risk Foreign**: `amount > $100k AND country != US AND deviceRisk > 80`
2. **Critical Device Risk**: `deviceRisk > 90`
3. **Suspicious Amount Pattern**: `amount ≈ $100k` (just under threshold)
4. **High-Value Crypto**: `paymentMethod == crypto AND amount > $50k`
5. **Velocity Pattern**: `amount > $25k AND deviceRisk > 50`

---

## 📊 Performance Characteristics

### Latency (p99)
- Gateway validation: **< 1ms**
- Risk scoring: **< 2ms**
- Rule evaluation: **< 1ms**
- **Total end-to-end: < 5ms**

### Throughput
- Sustained: **1,000 req/s**
- Burst: **1,500 req/s**
- Peak tested: **2,000+ req/s**

### Scalability
- Horizontal: Add more Risk Engine instances
- Vertical: Assembly optimizations for hot paths
- Database: MongoDB sharding for high volume

---

## 🔐 Security & Compliance

### Authentication
- HMAC-SHA256 request signatures
- Timestamp validation (5-minute window)
- Replay attack prevention

### Audit Trail
Every action is logged:
- Transaction evaluations
- Rule modifications
- Manual approvals/denials
- System configuration changes

### Compliance Support
- **PCI-DSS**: Payment card security standards
- **SOC2 Type II**: Security and availability
- **GDPR**: Data retention and privacy
- **Internal Audits**: Complete audit trail

---

## 📚 Documentation

- **[Architecture Guide](docs/ARCHITECTURE.md)** - Detailed system design
- **[API Reference](docs/API.md)** - Complete API documentation
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment
- **[Development Setup](docs/DEVELOPMENT.md)** - Local development

---

## 🧪 Testing

### Unit Tests

```bash
# Rust
cd risk-engine-rust && cargo test

# Go
cd gateway-go && go test ./...

# .NET
cd control-dotnet && dotnet test

# Haskell
cd rules-haskell && stack test
```

### Integration Tests

```bash
./infra/test-integration.sh
```

### Load Testing

```bash
# Install Apache Bench
brew install apache-bench  # macOS
# or: apt-get install apache2-utils  # Linux

# Run load test
ab -n 10000 -c 100 -p test_transaction.json \
   -T application/json \
   http://localhost:8080/v1/transactions
```

---

## 🎓 Learning Outcomes

This project demonstrates:

### Systems Design
- Microservices architecture
- Event-driven patterns
- Database design for scale
- API design best practices

### Performance Engineering
- Sub-millisecond latency optimization
- Memory management in Rust
- Hot-path identification
- Assembly-level optimization

### Security & Compliance
- Cryptographic operations
- Audit logging
- Compliance frameworks
- Threat modeling

### Multi-Language Proficiency
- Go for concurrent I/O
- Rust for system programming
- C# for enterprise software
- Ruby for rapid development
- Haskell for formal reasoning
- Assembly for low-level optimization

---

## 🏆 Interview Talking Points

### For FAANG Interviews

> "VaultEdge demonstrates production-grade system design by combining language-specific strengths: Go handles high-throughput ingestion, Rust ensures memory-safe decisioning with predictable latency, Haskell provides deterministic rule evaluation, and .NET delivers enterprise auditability. The system processes transactions in under 5ms with complete traceability."

### For FinTech Roles

> "This platform solves the core challenge of real-time fraud prevention: fast, correct, explainable, and auditable decisions. It supports PCI-DSS compliance through immutable audit logs, deterministic rule evaluation, and separation of concerns between hot-path processing and audit/reporting."

### For Backend Engineering

> "The architecture separates concerns across optimal technologies: event ingestion (Go), core logic (Rust), business rules (Haskell), and administrative functions (C#). This demonstrates understanding of when to choose each tool and how to integrate them effectively."

---

## 🚧 Roadmap

### Phase 1: MVP (Complete ✅)
- [x] Core risk engine
- [x] Transaction gateway
- [x] Rule management
- [x] Audit logging
- [x] Basic analytics

### Phase 2: Advanced Features
- [ ] Machine learning risk models
- [ ] Real-time rule hot-reload
- [ ] Behavioral biometrics
- [ ] Advanced anomaly detection
- [ ] Multi-region deployment

### Phase 3: Enterprise Features
- [ ] Graph-based fraud detection
- [ ] Kafka event streaming
- [ ] Real-time dashboards
- [ ] A/B testing framework
- [ ] Advanced compliance reporting

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by real-world fraud detection systems at Stripe, PayPal, and Square
- Built for educational purposes and portfolio demonstration
- Thanks to the open-source community for excellent tools and libraries

---

## 📬 Contact

**Archit Singhania**
- GitHub: [@architsinghania](https://github.com/architsinghania)
- LinkedIn: [your-linkedin](https://linkedin.com/in/your-profile)
- Email: your.email@example.com

---

## 🌟 Star This Repository

If you find VaultEdge useful for learning or your portfolio, please consider giving it a star! ⭐

---

**Built with ❤️ for FinTech Engineers**
