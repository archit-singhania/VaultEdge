# VaultEdge Development Guide

## Getting Started

This guide will help you set up VaultEdge for local development and understand the codebase structure.

---

## Prerequisites

### Required Tools

1. **Docker & Docker Compose**
   - macOS: `brew install docker docker-compose`
   - Linux: Follow [official docs](https://docs.docker.com/engine/install/)
   - Windows: Docker Desktop

2. **Go 1.21+**
   ```bash
   # macOS
   brew install go
   
   # Linux
   wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
   sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
   ```

3. **Rust 1.75+**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

4. **.NET 8.0+**
   ```bash
   # macOS
   brew install dotnet
   
   # Linux/Windows
   # https://dotnet.microsoft.com/download
   ```

5. **Ruby 3.0+**
   ```bash
   # macOS
   brew install ruby
   
   # Linux
   sudo apt-get install ruby-full
   ```

6. **Haskell Stack**
   ```bash
   curl -sSL https://get.haskellstack.org/ | sh
   ```

7. **NASM** (Assembly)
   ```bash
   # macOS
   brew install nasm
   
   # Linux
   sudo apt-get install nasm
   ```

---

## Project Structure

```
vaultedge/
├── gateway-go/              # Go API Gateway
│   ├── main.go             # Entry point
│   ├── go.mod              # Dependencies
│   └── README.md           # Gateway docs
│
├── risk-engine-rust/        # Rust Risk Engine
│   ├── src/
│   │   ├── main.rs         # HTTP server
│   │   └── lib.rs          # Core logic
│   ├── Cargo.toml          # Dependencies
│   └── README.md           # Engine docs
│
├── control-dotnet/          # C# Control Plane
│   ├── Program.cs          # Entry point
│   ├── Models.cs           # Data models
│   ├── Services.cs         # Business logic
│   ├── *.csproj            # Project file
│   └── README.md           # Control plane docs
│
├── analyst-ruby/            # Ruby Analyst Tools
│   ├── app.rb              # Sinatra app
│   ├── Gemfile             # Dependencies
│   └── README.md           # Analyst docs
│
├── rules-haskell/           # Haskell Rule Engine
│   ├── src/Rules/          # Rule modules
│   │   ├── Types.hs        # Data types
│   │   ├── Engine.hs       # Rule definitions
│   │   ├── Evaluator.hs    # Evaluation logic
│   │   └── Parser.hs       # DSL parser
│   ├── app/Main.hs         # CLI entry
│   ├── package.yaml        # Dependencies
│   └── README.md           # Haskell docs
│
├── asm-primitives/          # Assembly Optimizations
│   ├── hash.asm            # Fast hashing
│   ├── test.c              # C test harness
│   ├── Makefile            # Build script
│   └── README.md           # Assembly docs
│
├── mobile-swift/            # Swift iOS App
│   └── VaultEdgeReview/
│       ├── ContentView.swift
│       ├── TransactionDetailView.swift
│       └── TransactionViewModel.swift
│
├── infra/                   # Infrastructure Scripts
│   ├── setup.sh            # Initial setup
│   ├── start-all.sh        # Start services
│   ├── stop-all.sh         # Stop services
│   ├── test-integration.sh # Integration tests
│   └── mongo-init.js       # MongoDB setup
│
├── docs/                    # Documentation
│   ├── ARCHITECTURE.md     # System design
│   ├── API.md              # API reference
│   └── DEPLOYMENT.md       # Deployment guide
│
├── docker-compose.yml       # Docker orchestration
└── README.md               # Main documentation
```

---

## Setup Instructions

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/vaultedge.git
cd vaultedge

# Make scripts executable
chmod +x infra/*.sh

# Run setup (installs all dependencies)
./infra/setup.sh
```

### 2. Start Services

```bash
# Start all services
./infra/start-all.sh

# Wait for services to be ready (about 10 seconds)
sleep 10

# Verify all services
curl http://localhost:8080/health  # Gateway
curl http://localhost:8081/health  # Risk Engine
curl http://localhost:8082/health  # Control Plane
curl http://localhost:4567/health  # Analyst Tools
```

### 3. Run Tests

```bash
# Integration tests
./infra/test-integration.sh

# Unit tests (per component)
cd risk-engine-rust && cargo test
cd gateway-go && go test ./...
cd control-dotnet && dotnet test
cd rules-haskell && stack test
```

---

## Development Workflow

### Working on the Go Gateway

```bash
cd gateway-go

# Install dependencies
go mod download

# Run locally
MONGO_URI=mongodb://localhost:27017 \
RISK_ENGINE_URL=http://localhost:8081 \
PORT=8080 \
go run main.go

# Run tests
go test -v ./...

# Build
go build -o gateway main.go
```

### Working on the Rust Risk Engine

```bash
cd risk-engine-rust

# Install dependencies
cargo build

# Run locally
MONGO_URI=mongodb://localhost:27017 \
PORT=8081 \
HOME_COUNTRY=US \
cargo run

# Run tests
cargo test

# Run tests with output
cargo test -- --nocapture

# Build release
cargo build --release
```

### Working on the .NET Control Plane

```bash
cd control-dotnet

# Restore dependencies
dotnet restore

# Run locally
ASPNETCORE_URLS=http://localhost:8082 \
dotnet run

# Run tests
dotnet test

# Build
dotnet build

# Publish
dotnet publish -c Release
```

### Working on Ruby Analyst Tools

```bash
cd analyst-ruby

# Install dependencies
bundle install

# Run locally
PORT=4567 \
MONGO_URI=mongodb://localhost:27017 \
bundle exec ruby app.rb

# Run with auto-reload (development)
bundle exec rerun ruby app.rb
```

### Working on Haskell Rules

```bash
cd rules-haskell

# Build
stack build

# Run
stack exec vaultedge-rules evaluate

# Interactive REPL
stack ghci

# Test
stack test
```

### Working on Assembly Primitives

```bash
cd asm-primitives

# Build
make

# Test
./test_hash

# Clean
make clean
```

---

## Testing Individual Components

### Test Gateway

```bash
# Submit a test transaction
curl -X POST http://localhost:8080/v1/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "test_001",
      "amount": 100.00,
      "currency": "USD",
      "country": "US",
      "deviceRisk": 20,
      "timestamp": '$(date +%s)',
      "merchantId": "test_merchant",
      "customerId": "test_customer",
      "paymentMethod": "credit_card"
    },
    "signature": "test_sig"
  }'
```

### Test Risk Engine Directly

```bash
curl -X POST http://localhost:8081/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "transaction": {
      "id": "test_002",
      "amount": 150000.00,
      "currency": "USD",
      "country": "RU",
      "deviceRisk": 95,
      "timestamp": '$(date +%s)',
      "merchantId": "test",
      "customerId": "test",
      "paymentMethod": "crypto"
    }
  }'
```

### Test Control Plane

```bash
# Get all rules
curl http://localhost:8082/api/rules

# Get decisions
curl http://localhost:8082/api/decisions?limit=10

# Create a rule
curl -X POST http://localhost:8082/api/rules \
  -H "Content-Type: application/json" \
  -d '{
    "ruleName": "test_rule",
    "description": "Test rule",
    "expression": "amount > 1000",
    "createdBy": "developer"
  }'
```

### Test Analyst Tools

```bash
# Dashboard stats
curl http://localhost:4567/api/dashboard/stats?days=7

# High-risk transactions
curl http://localhost:4567/api/dashboard/high-risk?threshold=80

# Rule effectiveness
curl http://localhost:4567/api/dashboard/rule-effectiveness?days=30
```

---

## Common Development Tasks

### Add a New Fraud Rule (Rust)

Edit `risk-engine-rust/src/lib.rs`:

```rust
// Add to make_decision() method
if txn.amount > 200_000.0 && txn.payment_method == "wire_transfer" {
    triggered_rules.push("large_wire_transfer".to_string());
    explanation_parts.push("Large wire transfer detected".to_string());
}
```

### Add a New API Endpoint (Go)

Edit `gateway-go/main.go`:

```go
router.GET("/v1/status/:id", gateway.GetTransactionStatus)
```

### Add a New Dashboard Chart (Ruby)

Edit `analyst-ruby/app.rb`:

```ruby
get '/api/dashboard/hourly-stats' do
  content_type :json
  # Your aggregation logic
  json results
end
```

### Add a New Rule Type (Haskell)

Edit `rules-haskell/src/Rules/Types.hs`:

```haskell
data RuleExpr
  = CompareAmount CompareOp Scientific
  | CompareDeviceRisk CompareOp Int
  | CompareVelocity CompareOp Int  -- NEW
  | And RuleExpr RuleExpr
  | Or RuleExpr RuleExpr
```

---

## Debugging

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mongodb

# Gateway logs
tail -f /tmp/gateway.log

# Risk Engine logs (Rust outputs to stdout)
```

### MongoDB Shell

```bash
# Connect to MongoDB
docker exec -it vaultedge_mongodb_1 mongosh

# Switch to VaultEdge database
use vaultedge

# Query decisions
db.decisions.find().limit(10).pretty()

# Query audit logs
db.audit_logs.find().limit(10).pretty()

# Count transactions by decision
db.decisions.aggregate([
  { $group: { _id: "$decision", count: { $sum: 1 } } }
])
```

### Performance Profiling

```bash
# Rust profiling
cd risk-engine-rust
cargo install flamegraph
cargo flamegraph

# Go profiling
cd gateway-go
go test -cpuprofile cpu.prof -bench .
go tool pprof cpu.prof
```

---

## Code Style Guidelines

### Go
- Use `gofmt` for formatting
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Use meaningful variable names
- Add comments for exported functions

### Rust
- Use `cargo fmt` for formatting
- Use `cargo clippy` for linting
- Follow [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Prefer explicit error handling

### C#
- Use `dotnet format` for formatting
- Follow [C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- Use LINQ where appropriate
- Async/await for I/O operations

### Ruby
- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Use `rubocop` for linting
- Keep methods short and focused
- Prefer functional style

### Haskell
- Use `ormolu` or `stylish-haskell` for formatting
- Follow [Haskell Style Guide](https://kowainik.github.io/posts/2019-02-06-style-guide)
- Keep functions pure where possible
- Use type signatures

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>
```

### MongoDB Connection Issues

```bash
# Restart MongoDB
docker-compose restart mongodb

# Check MongoDB logs
docker-compose logs mongodb
```

### Rust Build Errors

```bash
# Clean and rebuild
cd risk-engine-rust
cargo clean
cargo build
```

### Go Module Issues

```bash
# Update dependencies
cd gateway-go
go mod tidy
go mod download
```

---

## IDE Setup

### VS Code

Recommended extensions:
- **Go**: ms-vscode.go
- **Rust**: rust-lang.rust-analyzer
- **C#**: ms-dotnettools.csharp
- **Ruby**: rebornix.ruby
- **Haskell**: haskell.haskell

### IntelliJ IDEA

- Install Go plugin
- Install Rust plugin
- For C#, use Rider instead

---

## Next Steps

1. Read the [Architecture Documentation](docs/ARCHITECTURE.md)
2. Review the [API Documentation](docs/API.md)
3. Try modifying a fraud rule
4. Add a new API endpoint
5. Write integration tests for your changes

---

## Getting Help

- **Issues**: Open a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Documentation**: Check `/docs` folder
- **Code Comments**: Read inline documentation

---

**Happy Coding! 🚀**
