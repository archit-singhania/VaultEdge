#!/bin/bash

# Quick Fix and Test Script

echo "🔧 Fixing Control Plane Port Mapping"
echo "====================================="
echo ""

# Change to repo root
cd /Users/architsinghania/Documents/vaultedge

echo "1️⃣  Restarting Control Plane with correct port..."
docker compose up -d control-plane

echo ""
echo "2️⃣  Waiting for service to start..."
sleep 10

echo ""
echo "3️⃣  Testing all services..."
echo ""

# Test Gateway
echo -n "Gateway (8080): "
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ UP"
else
    echo "❌ DOWN"
fi

# Test Risk Engine
echo -n "Risk Engine (8081): "
if curl -s http://localhost:8081/health > /dev/null 2>&1; then
    echo "✅ UP"
else
    echo "❌ DOWN"
fi

# Test Control Plane
echo -n "Control Plane (8082): "
if curl -s http://localhost:8082/health > /dev/null 2>&1; then
    echo "✅ UP"
    curl -s http://localhost:8082/health
else
    echo "❌ DOWN"
    echo "Showing logs..."
    docker compose logs --tail=30 control-plane
fi

# Test Analyst Tools
echo -n "Analyst Tools (4567): "
if curl -s http://localhost:4567/health > /dev/null 2>&1; then
    echo "✅ UP"
else
    echo "❌ DOWN"
fi

echo ""
echo "====================================="
echo "✅ All services should now be working!"
echo ""
echo "Test with a transaction:"
echo 'curl -X POST http://localhost:8080/v1/transactions \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{'
echo '    "transaction": {'
echo '      "id": "txn_test_001",'
echo '      "amount": 50.00,'
echo '      "currency": "USD",'
echo '      "country": "US",'
echo '      "deviceRisk": 10,'
echo '      "timestamp": '$(date +%s)','
echo '      "merchantId": "merch_001",'
echo '      "customerId": "cust_001",'
echo '      "paymentMethod": "credit_card"'
echo '    },'
echo '    "signature": "test_sig"'
echo '  }'"'"
echo ""
