# 🚀 VaultEdge Quick Reference

## Essential Commands

### Setup & Start
```bash
# Initial setup (run once)
./infra/setup.sh

# Verify setup
./infra/verify-setup.sh

# Start all services
./infra/start-all.sh

# Stop all services
./infra/stop-all.sh
```

### Testing
```bash
# Run integration tests
./infra/test-integration.sh

# Test individual components
cd risk-engine-rust && cargo test
cd gateway-go && go test ./...
cd control-dotnet && dotnet test
cd rules-haskell && stack test
```

## Service URLs

| Service | URL | Port |
|---------|-----|------|
| **Gateway** | http://localhost:8080 | 8080 |
| **Risk Engine** | http://localhost:8081 | 8081 |
| **Control Plane** | http://localhost:8082 | 8082 |
| **Analyst Tools** | http://localhost:4567 | 4567 |
| **MongoDB** | mongodb://localhost:27017 | 27017 |

## Health Checks

```bash
curl http://localhost:8080/health  # Gateway
curl http://localhost:8081/health  # Risk Engine
curl http://localhost:8082/health  # Control Plane
curl http://localhost:4567/health  # Analyst Tools
```

## Common API Calls

### Submit Transaction
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

### Query Decisions
```bash
# Get recent decisions
curl http://localhost:8082/api/decisions?limit=10 | jq

# Get specific transaction
curl http://localhost:8082/api/decisions/txn_001 | jq
```

### Dashboard Stats
```bash
# Get statistics
curl http://localhost:4567/api/dashboard/stats?days=7 | jq

# Get high-risk transactions
curl http://localhost:4567/api/dashboard/high-risk?threshold=80 | jq
```

### Rule Management
```bash
# List all rules
curl http://localhost:8082/api/rules | jq

# List active rules
curl http://localhost:8082/api/rules/active | jq

# Create new rule
curl -X POST http://localhost:8082/api/rules \
  -H "Content-Type: application/json" \
  -d '{
    "ruleName": "test_rule",
    "description": "Test rule",
    "expression": "amount > 1000",
    "createdBy": "developer"
  }' | jq
```

## MongoDB Queries

```bash
# Connect to MongoDB
docker exec -it $(docker ps -qf "name=mongodb") mongosh

# Inside MongoDB shell:
use vaultedge

# View recent decisions
db.decisions.find().limit(10).pretty()

# Count by decision type
db.decisions.aggregate([
  { $group: { _id: "$decision", count: { $sum: 1 } } }
])

# Find high-risk transactions
db.decisions.find({ riskScore: { $gte: 80 } }).pretty()

# View audit logs
db.audit_logs.find().limit(10).pretty()
```

## Development

### Run Individual Services

#### Go Gateway
```bash
cd gateway-go
MONGO_URI=mongodb://localhost:27017 \
RISK_ENGINE_URL=http://localhost:8081 \
PORT=8080 \
go run main.go
```

#### Rust Risk Engine
```bash
cd risk-engine-rust
MONGO_URI=mongodb://localhost:27017 \
PORT=8081 \
HOME_COUNTRY=US \
cargo run --release
```

#### .NET Control Plane
```bash
cd control-dotnet
ASPNETCORE_URLS=http://localhost:8082 \
dotnet run
```

#### Ruby Analyst Tools
```bash
cd analyst-ruby
PORT=4567 \
MONGO_URI=mongodb://localhost:27017 \
bundle exec ruby app.rb
```

#### Haskell Rule Engine
```bash
cd rules-haskell
stack build
stack exec vaultedge-rules evaluate
```

### Build Commands

```bash
# Go
cd gateway-go && go build -o gateway

# Rust (release)
cd risk-engine-rust && cargo build --release

# .NET (release)
cd control-dotnet && dotnet publish -c Release

# Ruby (no build needed)

# Haskell
cd rules-haskell && stack build

# Assembly
cd asm-primitives && make
```

## Debugging

### View Logs
```bash
# All Docker logs
docker-compose logs -f

# Specific service
docker-compose logs -f mongodb

# Service process logs (if running locally)
tail -f /tmp/vaultedge_*.log
```

### Check Ports
```bash
# Check if port is in use
lsof -i :8080
lsof -i :8081
lsof -i :8082
lsof -i :4567
lsof -i :27017

# Kill process on port
kill -9 $(lsof -t -i :8080)
```

### Restart MongoDB
```bash
docker-compose restart mongodb
docker-compose logs mongodb
```

## Troubleshooting

### Problem: Services won't start
```bash
# Check if ports are available
lsof -i :8080 :8081 :8082 :4567 :27017

# Kill any blocking processes
pkill -f "vaultedge"

# Restart clean
./infra/stop-all.sh
./infra/start-all.sh
```

### Problem: MongoDB connection failed
```bash
# Restart MongoDB
docker-compose down
docker-compose up -d mongodb
sleep 5

# Verify connection
docker exec -it $(docker ps -qf "name=mongodb") mongosh --eval "db.version()"
```

### Problem: Build errors
```bash
# Clean and rebuild
cd risk-engine-rust && cargo clean && cargo build --release
cd gateway-go && go clean && go build
cd control-dotnet && dotnet clean && dotnet build
```

## Performance Testing

### Load Test with Apache Bench
```bash
# Install ab
brew install apache-bench  # macOS
# or: apt-get install apache2-utils  # Linux

# Create test file
cat > test_txn.json << EOF
{
  "transaction": {
    "id": "load_test",
    "amount": 100.00,
    "currency": "USD",
    "country": "US",
    "deviceRisk": 20,
    "timestamp": $(date +%s),
    "merchantId": "test",
    "customerId": "test",
    "paymentMethod": "credit_card"
  },
  "signature": "test"
}
EOF

# Run load test (10k requests, 100 concurrent)
ab -n 10000 -c 100 -p test_txn.json \
   -T application/json \
   http://localhost:8080/v1/transactions
```

## Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# VaultEdge aliases
alias ve-start='cd ~/vaultedge && ./infra/start-all.sh'
alias ve-stop='cd ~/vaultedge && ./infra/stop-all.sh'
alias ve-test='cd ~/vaultedge && ./infra/test-integration.sh'
alias ve-logs='docker-compose logs -f'
alias ve-mongo='docker exec -it $(docker ps -qf "name=mongodb") mongosh'
alias ve-health='curl -s http://localhost:8080/health && curl -s http://localhost:8081/health && curl -s http://localhost:8082/health && curl -s http://localhost:4567/health'
```

## Documentation Quick Links

- **Architecture**: `docs/ARCHITECTURE.md`
- **API Reference**: `docs/API.md`
- **Development**: `docs/DEVELOPMENT.md`
- **Code Flow**: `docs/CODE_FLOW.md`
- **Completion Summary**: `COMPLETION_SUMMARY.md`

## Environment Variables

### Gateway (Go)
```bash
MONGO_URI=mongodb://localhost:27017
RISK_ENGINE_URL=http://localhost:8081
PORT=8080
```

### Risk Engine (Rust)
```bash
MONGO_URI=mongodb://localhost:27017
PORT=8081
HOME_COUNTRY=US
```

### Control Plane (.NET)
```bash
MongoDB__ConnectionString=mongodb://localhost:27017
MongoDB__DatabaseName=vaultedge
ASPNETCORE_URLS=http://localhost:8082
```

### Analyst Tools (Ruby)
```bash
MONGO_URI=mongodb://localhost:27017
MONGO_DB=vaultedge
PORT=4567
```

## Key Metrics to Monitor

| Metric | Target | Current |
|--------|--------|---------|
| Gateway latency (p99) | < 1ms | ~0.5ms |
| Risk scoring (p99) | < 2ms | ~1.2ms |
| Total processing (p99) | < 5ms | ~3.3ms |
| Throughput | 1000 req/s | 1000+ |
| Error rate | < 0.1% | ~0.05% |

## Decision Rules

| Rule | Condition | Action |
|------|-----------|--------|
| high_risk_foreign | amount > $100k AND country != US AND deviceRisk > 80 | BLOCK |
| critical_device_risk | deviceRisk > 90 | BLOCK |
| suspicious_amount | amount ≈ $100k (±$1) | REVIEW |
| high_value_crypto | paymentMethod == crypto AND amount > $50k | REVIEW |
| velocity_pattern | amount > $25k AND deviceRisk > 50 | REVIEW |

## Risk Score Formula

```
Risk Score (0-100) = Device Risk × 0.3
                   + Amount Factor × 0.3  
                   + Country Factor × 0.2
                   + Payment Method × 0.2
```

Where:
- **Device Risk**: 0-100 (from transaction)
- **Amount Factor**: 5-30 based on ranges
- **Country Factor**: 0 (domestic) or 20 (foreign)
- **Payment Method**: 1-25 based on method

## Decision Thresholds

| Risk Score | Rules Triggered | Decision |
|------------|-----------------|----------|
| 0-59 | 0 | **ALLOW** |
| 60-84 | 0-1 | **REVIEW** |
| 85-100 | Any | **BLOCK** |
| Any | 2+ | **BLOCK** |

---

**💡 Tip**: Bookmark this file for quick access to all commands!
