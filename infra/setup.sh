#!/bin/bash

# VaultEdge Setup Script
# Sets up all dependencies and initializes the system

set -e

echo "🏦 VaultEdge Setup Script"
echo "========================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect OS
OS="$(uname -s)"
echo "Detected OS: $OS"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
echo "📦 Checking Docker..."
if command_exists docker; then
    echo -e "${GREEN}✓ Docker found${NC}"
else
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Check Docker Compose
echo "📦 Checking Docker Compose..."
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker Compose found${NC}"
else
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

# Check Go
echo "📦 Checking Go..."
if command_exists go; then
    GO_VERSION=$(go version | awk '{print $3}')
    echo -e "${GREEN}✓ Go found: $GO_VERSION${NC}"
else
    echo "⚠️  Go not found. Install Go 1.21+ from https://golang.org/dl/"
fi

# Check Rust
echo "📦 Checking Rust..."
if command_exists cargo; then
    RUST_VERSION=$(cargo --version | awk '{print $2}')
    echo -e "${GREEN}✓ Rust found: $RUST_VERSION${NC}"
else
    echo "⚠️  Rust not found. Install from https://rustup.rs/"
fi

# Check .NET
echo "📦 Checking .NET..."
if command_exists dotnet; then
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✓ .NET found: $DOTNET_VERSION${NC}"
else
    echo "⚠️  .NET not found. Install .NET 8.0+ from https://dotnet.microsoft.com/download"
fi

# Check Ruby
echo "📦 Checking Ruby..."
if command_exists ruby; then
    RUBY_VERSION=$(ruby --version | awk '{print $2}')
    echo -e "${GREEN}✓ Ruby found: $RUBY_VERSION${NC}"
else
    echo "⚠️  Ruby not found. Install Ruby 3.0+ from https://www.ruby-lang.org/"
fi

# Check Haskell (Stack)
echo "📦 Checking Haskell (Stack)..."
if command_exists stack; then
    STACK_VERSION=$(stack --version | head -n 1 | awk '{print $2}')
    echo -e "${GREEN}✓ Stack found: $STACK_VERSION${NC}"
else
    echo "⚠️  Stack not found. Install from https://docs.haskellstack.org/en/stable/README/"
fi

# Check NASM (for assembly)
echo "📦 Checking NASM..."
if command_exists nasm; then
    NASM_VERSION=$(nasm -v | awk '{print $3}')
    echo -e "${GREEN}✓ NASM found: $NASM_VERSION${NC}"
else
    echo "⚠️  NASM not found. Install with: brew install nasm (macOS) or apt-get install nasm (Linux)"
fi

echo ""
echo "📥 Installing dependencies..."
echo ""

# Install Go dependencies
if command_exists go; then
    echo "Installing Go dependencies..."
    cd gateway-go
    go mod download
    go mod tidy
    cd ..
    echo -e "${GREEN}✓ Go dependencies installed${NC}"
fi

# Install Rust dependencies
if command_exists cargo; then
    echo "Installing Rust dependencies..."
    cd risk-engine-rust
    cargo build --release
    cd ..
    echo -e "${GREEN}✓ Rust dependencies installed${NC}"
fi

# Install .NET dependencies
if command_exists dotnet; then
    echo "Installing .NET dependencies..."
    cd control-dotnet
    dotnet restore
    cd ..
    echo -e "${GREEN}✓ .NET dependencies installed${NC}"
fi

# Install Ruby dependencies
if command_exists ruby && command_exists bundle; then
    echo "Installing Ruby dependencies..."
    cd analyst-ruby
    bundle install
    cd ..
    echo -e "${GREEN}✓ Ruby dependencies installed${NC}"
fi

# Build Haskell project
if command_exists stack; then
    echo "Building Haskell project..."
    cd rules-haskell
    stack build
    cd ..
    echo -e "${GREEN}✓ Haskell project built${NC}"
fi

# Build Assembly primitives
if command_exists nasm; then
    echo "Building Assembly primitives..."
    cd asm-primitives
    make clean
    make
    cd ..
    echo -e "${GREEN}✓ Assembly primitives built${NC}"
fi

echo ""
echo "🗄️  Setting up MongoDB..."
docker-compose up -d mongodb
sleep 5
echo -e "${GREEN}✓ MongoDB started${NC}"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start all services: ./infra/start-all.sh"
echo "2. Run integration tests: ./infra/test-integration.sh"
echo "3. View logs: docker-compose logs -f"
echo ""
