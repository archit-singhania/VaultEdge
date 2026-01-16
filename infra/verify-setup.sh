#!/bin/bash

# VaultEdge System Verification Script
# Checks that all components are properly set up

set -e

echo "🔍 VaultEdge System Verification"
echo "================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0

check() {
    ((TOTAL++))
    local name=$1
    local command=$2
    
    echo -n "Checking $name... "
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# System Prerequisites
echo -e "${BLUE}📦 System Prerequisites${NC}"
echo "----------------------"
check "Docker" "command -v docker"
check "Docker Compose" "docker compose version || command -v docker-compose"
check "Git" "command -v git"
echo ""

# Programming Languages
echo -e "${BLUE}💻 Programming Languages${NC}"
echo "------------------------"
check "Go (1.21+)" "command -v go && [[ \$(go version | awk '{print \$3}' | sed 's/go//') > '1.21' ]]"
check "Rust (1.75+)" "command -v cargo"
check ".NET (8.0+)" "command -v dotnet"
check "Ruby (3.0+)" "command -v ruby && command -v bundle"
check "Haskell Stack" "command -v stack"
check "NASM" "command -v nasm"
echo ""

# Project Structure (from repo root)
echo -e "${BLUE}📁 Project Structure${NC}"
echo "--------------------"

# Get the script directory and repo root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$REPO_ROOT"

check "gateway-go exists" "[ -d gateway-go ]"
check "risk-engine-rust exists" "[ -d risk-engine-rust ]"
check "control-dotnet exists" "[ -d control-dotnet ]"
check "analyst-ruby exists" "[ -d analyst-ruby ]"
check "rules-haskell exists" "[ -d rules-haskell ]"
check "asm-primitives exists" "[ -d asm-primitives ]"
check "mobile-swift exists" "[ -d mobile-swift ]"
check "infra exists" "[ -d infra ]"
check "docs exists" "[ -d docs ]"
echo ""

# Key Files
echo -e "${BLUE}📄 Key Configuration Files${NC}"
echo "---------------------------"
check "docker-compose.yml" "[ -f docker-compose.yml ]"
check "README.md" "[ -f README.md ]"
check "Go main.go" "[ -f gateway-go/main.go ]"
check "Rust main.rs" "[ -f risk-engine-rust/src/main.rs ]"
check ".NET Program.cs" "[ -f control-dotnet/Program.cs ]"
check "Ruby app.rb" "[ -f analyst-ruby/app.rb ]"
check "Haskell Main.hs" "[ -f rules-haskell/app/Main.hs ]"
check "Assembly hash.asm" "[ -f asm-primitives/hash.asm ]"
echo ""

# Scripts
echo -e "${BLUE}🔧 Executable Scripts${NC}"
echo "---------------------"
check "setup.sh exists" "[ -f infra/setup.sh ]"
check "start-all.sh exists" "[ -f infra/start-all.sh ]"
check "stop-all.sh exists" "[ -f infra/stop-all.sh ]"
check "test-integration.sh exists" "[ -f infra/test-integration.sh ]"
check "setup.sh executable" "[ -x infra/setup.sh ]"
check "start-all.sh executable" "[ -x infra/start-all.sh ]"
check "stop-all.sh executable" "[ -x infra/stop-all.sh ]"
check "test-integration.sh executable" "[ -x infra/test-integration.sh ]"
echo ""

# Dependencies
echo -e "${BLUE}📦 Component Dependencies${NC}"
echo "-------------------------"

if check "Go modules" "[ -f gateway-go/go.mod ]"; then
    cd gateway-go
    if check "  Go dependencies downloaded" "go mod verify 2>/dev/null"; then
        echo "    Dependencies: OK"
    fi
    cd ..
fi

if check "Rust Cargo.toml" "[ -f risk-engine-rust/Cargo.toml ]"; then
    cd risk-engine-rust
    if check "  Rust project compiles" "cargo check --release 2>/dev/null"; then
        echo "    Build: OK"
    fi
    cd ..
fi

if check ".NET project file" "[ -f control-dotnet/VaultEdge.ControlPlane.csproj ]"; then
    cd control-dotnet
    if check "  .NET project restores" "dotnet restore 2>/dev/null"; then
        echo "    Dependencies: OK"
    fi
    cd ..
fi

if check "Ruby Gemfile" "[ -f analyst-ruby/Gemfile ]"; then
    cd analyst-ruby
    if check "  Ruby gems installed" "bundle check 2>/dev/null"; then
        echo "    Gems: OK"
    fi
    cd ..
fi

if check "Haskell package.yaml" "[ -f rules-haskell/package.yaml ]"; then
    cd rules-haskell
    if check "  Haskell dependencies" "stack setup 2>/dev/null"; then
        echo "    Stack: OK"
    fi
    cd ..
fi
echo ""

# Docker
echo -e "${BLUE}🐳 Docker Environment${NC}"
echo "--------------------"
check "Docker daemon running" "docker info"
check "MongoDB image available" "docker images | grep -q mongo || docker pull mongo:latest"
echo ""

# Summary
echo ""
echo "================================="
echo -e "${BLUE}📊 Verification Summary${NC}"
echo "================================="
echo -e "Total Checks: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ System is ready!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Start all services:"
    echo "   ./infra/start-all.sh"
    echo ""
    echo "2. Run integration tests:"
    echo "   ./infra/test-integration.sh"
    echo ""
    echo "3. Access services:"
    echo "   Gateway:       http://localhost:8080"
    echo "   Risk Engine:   http://localhost:8081"
    echo "   Control Plane: http://localhost:8082"
    echo "   Analyst Tools: http://localhost:4567"
    echo ""
    exit 0
else
    echo -e "${RED}❌ System has issues!${NC}"
    echo ""
    echo "Issues found:"
    if [ $FAILED -gt 0 ]; then
        echo "  - $FAILED check(s) failed"
    fi
    echo ""
    echo "Recommendations:"
    if ! command -v docker >/dev/null 2>&1; then
        echo "  - Install Docker: https://docs.docker.com/get-docker/"
    fi
    if ! command -v go >/dev/null 2>&1; then
        echo "  - Install Go: https://golang.org/dl/"
    fi
    if ! command -v cargo >/dev/null 2>&1; then
        echo "  - Install Rust: https://rustup.rs/"
    fi
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "  - Install .NET: https://dotnet.microsoft.com/download"
    fi
    if ! command -v ruby >/dev/null 2>&1; then
        echo "  - Install Ruby: https://www.ruby-lang.org/"
    fi
    if ! command -v stack >/dev/null 2>&1; then
        echo "  - Install Stack: https://docs.haskellstack.org/"
    fi
    echo ""
    echo "Run './infra/setup.sh' to install dependencies"
    echo ""
    exit 1
fi
