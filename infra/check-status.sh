#!/bin/bash

# VaultEdge Status Check Script

echo "🔍 VaultEdge System Status Check"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 Docker Container Status${NC}"
echo "----------------------------"
docker compose ps
echo ""

echo -e "${BLUE}🏥 Health Check Results${NC}"
echo "------------------------"

# Gateway
echo -n "Gateway (8080): "
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
    curl -s http://localhost:8080/health | jq 2>/dev/null || curl -s http://localhost:8080/health
else
    echo -e "${RED}✗ DOWN${NC}"
fi
echo ""

# Risk Engine
echo -n "Risk Engine (8081): "
if curl -s http://localhost:8081/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
    curl -s http://localhost:8081/health | jq 2>/dev/null || curl -s http://localhost:8081/health
else
    echo -e "${RED}✗ DOWN${NC}"
fi
echo ""

# Control Plane
echo -n "Control Plane (8082): "
if curl -s http://localhost:8082/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
    curl -s http://localhost:8082/health | jq 2>/dev/null || curl -s http://localhost:8082/health
else
    echo -e "${RED}✗ DOWN${NC}"
    echo -e "${YELLOW}Checking logs for control-plane...${NC}"
    docker compose logs --tail=20 control-plane
fi
echo ""

# Analyst Tools
echo -n "Analyst Tools (4567): "
if curl -s http://localhost:4567/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
    curl -s http://localhost:4567/health | jq 2>/dev/null || curl -s http://localhost:4567/health
else
    echo -e "${RED}✗ DOWN${NC}"
fi
echo ""

echo -e "${BLUE}🗄️  MongoDB Status${NC}"
echo "-------------------"
if docker compose ps mongodb | grep -q "healthy"; then
    echo -e "${GREEN}✓ MongoDB is healthy${NC}"
else
    echo -e "${YELLOW}⚠ MongoDB status unknown${NC}"
fi
echo ""

echo -e "${BLUE}📝 Recent Logs (Last 10 Lines Each Service)${NC}"
echo "--------------------------------------------"

for service in gateway risk-engine control-plane analyst-tools; do
    echo ""
    echo -e "${YELLOW}=== $service ===${NC}"
    docker compose logs --tail=10 $service
done

echo ""
echo "=================================="
echo "For detailed logs of a specific service:"
echo "  docker compose logs -f gateway"
echo "  docker compose logs -f risk-engine"
echo "  docker compose logs -f control-plane"
echo "  docker compose logs -f analyst-tools"
echo ""
