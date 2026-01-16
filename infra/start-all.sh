#!/bin/bash

# VaultEdge - Start All Services
# Starts all microservices in the correct order

set -e

echo "🚀 Starting VaultEdge Services"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Start MongoDB first
echo "1️⃣  Starting MongoDB..."
docker-compose up -d mongodb
sleep 5
echo -e "${GREEN}✓ MongoDB started${NC}"
echo ""

# Start Rust Risk Engine
echo "2️⃣  Starting Risk Engine (Rust)..."
cd risk-engine-rust
MONGO_URI=mongodb://localhost:27017 PORT=8081 cargo run --release &
RUST_PID=$!
cd ..
echo -e "${GREEN}✓ Risk Engine started (PID: $RUST_PID)${NC}"
sleep 3
echo ""

# Start Go Gateway
echo "3️⃣  Starting Gateway (Go)..."
cd gateway-go
MONGO_URI=mongodb://localhost:27017 PORT=8080 RISK_ENGINE_URL=http://localhost:8081 go run main.go &
GO_PID=$!
cd ..
echo -e "${GREEN}✓ Gateway started (PID: $GO_PID)${NC}"
sleep 2
echo ""

# Start .NET Control Plane
echo "4️⃣  Starting Control Plane (.NET)..."
cd control-dotnet
ASPNETCORE_URLS=http://localhost:8082 dotnet run &
DOTNET_PID=$!
cd ..
echo -e "${GREEN}✓ Control Plane started (PID: $DOTNET_PID)${NC}"
sleep 2
echo ""

# Start Ruby Analyst Tools
echo "5️⃣  Starting Analyst Tools (Ruby)..."
cd analyst-ruby
PORT=4567 MONGO_URI=mongodb://localhost:27017 bundle exec ruby app.rb &
RUBY_PID=$!
cd ..
echo -e "${GREEN}✓ Analyst Tools started (PID: $RUBY_PID)${NC}"
sleep 2
echo ""

# Save PIDs to file
echo "$RUST_PID" > /tmp/vaultedge_rust.pid
echo "$GO_PID" > /tmp/vaultedge_go.pid
echo "$DOTNET_PID" > /tmp/vaultedge_dotnet.pid
echo "$RUBY_PID" > /tmp/vaultedge_ruby.pid

echo "=============================="
echo "✅ All services started!"
echo "=============================="
echo ""
echo "Service URLs:"
echo "  Gateway:       http://localhost:8080"
echo "  Risk Engine:   http://localhost:8081"
echo "  Control Plane: http://localhost:8082"
echo "  Analyst Tools: http://localhost:4567"
echo ""
echo "Health Checks:"
echo "  curl http://localhost:8080/health"
echo "  curl http://localhost:8081/health"
echo "  curl http://localhost:8082/health"
echo "  curl http://localhost:4567/health"
echo ""
echo "To stop all services: ./infra/stop-all.sh"
echo ""
