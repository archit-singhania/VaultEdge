#!/bin/bash

# VaultEdge - Start All Services
# Starts all microservices in the correct order

set -e

# Get the script directory and repo root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "🚀 Starting VaultEdge Services"
echo "=============================="
echo "Repository: $REPO_ROOT"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Change to repo root
cd "$REPO_ROOT"

# Start MongoDB first
echo "1️⃣  Starting MongoDB..."
docker compose up -d mongodb
echo "Waiting for MongoDB to be ready..."
sleep 10

# Wait for MongoDB health check
MAX_WAIT=30
WAITED=0
until docker compose ps mongodb | grep -q "healthy" || [ $WAITED -eq $MAX_WAIT ]; do
    echo "Waiting for MongoDB health check... ($WAITED/$MAX_WAIT)"
    sleep 2
    ((WAITED+=2))
done

if [ $WAITED -eq $MAX_WAIT ]; then
    echo -e "${YELLOW}⚠ MongoDB health check timeout, continuing anyway...${NC}"
else
    echo -e "${GREEN}✓ MongoDB is healthy${NC}"
fi
echo ""

# Option 1: Use Docker Compose for all services (RECOMMENDED)
echo -e "${BLUE}Starting all services with Docker Compose...${NC}"
docker compose up -d

echo ""
echo "Waiting for services to start..."
sleep 15

echo ""
echo "=============================="
echo "✅ All services started!"
echo "=============================="
echo ""
echo "Service URLs:"
echo "  Gateway:       http://localhost:8080"
echo "  Risk Engine:   http://localhost:8081"
echo "  Control Plane: http://localhost:8082"
echo "  Analyst Tools: http://localhost:4567"
echo "  MongoDB:       mongodb://localhost:27017"
echo ""
echo "Health Checks:"
echo "  curl http://localhost:8080/health"
echo "  curl http://localhost:8081/health"
echo "  curl http://localhost:8082/health"
echo "  curl http://localhost:4567/health"
echo ""
echo "View Logs:"
echo "  docker compose logs -f gateway"
echo "  docker compose logs -f risk-engine"
echo "  docker compose logs -f control-plane"
echo "  docker compose logs -f analyst-tools"
echo ""
echo "To stop all services: ./infra/stop-all.sh"
echo ""
