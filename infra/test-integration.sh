#!/bin/bash

# VaultEdge Integration Test Script
# Tests the complete end-to-end transaction flow

set -e

echo "🧪 VaultEdge Integration Test Suite"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GATEWAY_URL="http://localhost:8080"
RISK_ENGINE_URL="http://localhost:8081"
CONTROL_PLANE_URL="http://localhost:8082"
ANALYST_TOOLS_URL="http://localhost:4567"

# Test counters
PASSED=0
FAILED=0

# Helper functions
test_endpoint() {
    local name=$1
    local url=$2
    echo -n "Testing $name... "
    
    if curl -sf "$url/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
    fi
}

test_transaction() {
    local name=$1
    local txn_file=$2
    echo -n "Testing transaction: $name... "
    
    response=$(curl -sf -X POST "$GATEWAY_URL/v1/transactions" \
        -H "Content-Type: application/json" \
        -d @"$txn_file" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        echo "  Response: $response"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "  Error: $response"
        ((FAILED++))
    fi
}

# Wait for services
echo "⏳ Waiting for services to be ready..."
sleep 5

# Test 1: Health Checks
echo ""
echo "📋 Test 1: Service Health Checks"
echo "--------------------------------"
test_endpoint "Gateway" "$GATEWAY_URL"
test_endpoint "Risk Engine" "$RISK_ENGINE_URL"
test_endpoint "Control Plane" "$CONTROL_PLANE_URL"
test_endpoint "Analyst Tools" "$ANALYST_TOOLS_URL"

# Test 2: Low Risk Transaction
echo ""
echo "📋 Test 2: Low Risk Transaction (Should ALLOW)"
echo "----------------------------------------------"
cat > /tmp/low_risk_txn.json << EOF
{
  "transaction": {
    "id": "txn_test_low_001",
    "amount": 50.00,
    "currency": "USD",
    "country": "US",
    "deviceRisk": 10,
    "timestamp": $(date +%s),
    "merchantId": "merch_test_001",
    "customerId": "cust_test_001",
    "paymentMethod": "credit_card"
  },
  "signature": "test_signature_low"
}
EOF
test_transaction "Low Risk" "/tmp/low_risk_txn.json"

# Test 3: Medium Risk Transaction
echo ""
echo "📋 Test 3: Medium Risk Transaction (Should REVIEW)"
echo "--------------------------------------------------"
cat > /tmp/medium_risk_txn.json << EOF
{
  "transaction": {
    "id": "txn_test_medium_001",
    "amount": 75000.00,
    "currency": "USD",
    "country": "CA",
    "deviceRisk": 65,
    "timestamp": $(date +%s),
    "merchantId": "merch_test_002",
    "customerId": "cust_test_002",
    "paymentMethod": "debit_card"
  },
  "signature": "test_signature_medium"
}
EOF
test_transaction "Medium Risk" "/tmp/medium_risk_txn.json"

# Test 4: High Risk Transaction
echo ""
echo "📋 Test 4: High Risk Transaction (Should BLOCK)"
echo "-----------------------------------------------"
cat > /tmp/high_risk_txn.json << EOF
{
  "transaction": {
    "id": "txn_test_high_001",
    "amount": 150000.00,
    "currency": "USD",
    "country": "RU",
    "deviceRisk": 95,
    "timestamp": $(date +%s),
    "merchantId": "merch_test_003",
    "customerId": "cust_test_003",
    "paymentMethod": "crypto"
  },
  "signature": "test_signature_high"
}
EOF
test_transaction "High Risk" "/tmp/high_risk_txn.json"

# Test 5: Rule Management
echo ""
echo "📋 Test 5: Control Plane - Rule Management"
echo "------------------------------------------"
echo -n "Fetching active rules... "
rules=$(curl -sf "$CONTROL_PLANE_URL/api/rules/active" 2>&1)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "  Active rules count: $(echo $rules | jq '. | length')"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Test 6: Decision Query
echo ""
echo "📋 Test 6: Control Plane - Decision Query"
echo "-----------------------------------------"
echo -n "Fetching recent decisions... "
decisions=$(curl -sf "$CONTROL_PLANE_URL/api/decisions?limit=10" 2>&1)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "  Decisions retrieved: $(echo $decisions | jq '. | length')"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Test 7: Analyst Dashboard
echo ""
echo "📋 Test 7: Analyst Tools - Dashboard Stats"
echo "------------------------------------------"
echo -n "Fetching dashboard statistics... "
stats=$(curl -sf "$ANALYST_TOOLS_URL/api/dashboard/stats?days=7" 2>&1)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "  Stats: $stats"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Test 8: Direct Risk Engine Evaluation
echo ""
echo "📋 Test 8: Risk Engine - Direct Evaluation"
echo "------------------------------------------"
echo -n "Direct risk evaluation... "
cat > /tmp/direct_eval.json << EOF
{
  "transaction": {
    "id": "txn_direct_001",
    "amount": 99999.50,
    "currency": "USD",
    "country": "US",
    "deviceRisk": 85,
    "timestamp": $(date +%s),
    "merchantId": "merch_direct_001",
    "customerId": "cust_direct_001",
    "paymentMethod": "bank_transfer"
  }
}
EOF
eval_result=$(curl -sf -X POST "$RISK_ENGINE_URL/v1/evaluate" \
    -H "Content-Type: application/json" \
    -d @/tmp/direct_eval.json 2>&1)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "  Risk Score: $(echo $eval_result | jq -r '.result.riskScore')"
    echo "  Decision: $(echo $eval_result | jq -r '.result.decision')"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Summary
echo ""
echo "===================================="
echo "📊 Test Summary"
echo "===================================="
echo -e "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
fi
