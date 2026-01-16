#!/bin/bash

# VaultEdge - Stop All Services

echo "🛑 Stopping VaultEdge Services"
echo "=============================="
echo ""

# Stop services by PID
if [ -f /tmp/vaultedge_rust.pid ]; then
    RUST_PID=$(cat /tmp/vaultedge_rust.pid)
    kill $RUST_PID 2>/dev/null && echo "✓ Stopped Risk Engine (PID: $RUST_PID)"
    rm /tmp/vaultedge_rust.pid
fi

if [ -f /tmp/vaultedge_go.pid ]; then
    GO_PID=$(cat /tmp/vaultedge_go.pid)
    kill $GO_PID 2>/dev/null && echo "✓ Stopped Gateway (PID: $GO_PID)"
    rm /tmp/vaultedge_go.pid
fi

if [ -f /tmp/vaultedge_dotnet.pid ]; then
    DOTNET_PID=$(cat /tmp/vaultedge_dotnet.pid)
    kill $DOTNET_PID 2>/dev/null && echo "✓ Stopped Control Plane (PID: $DOTNET_PID)"
    rm /tmp/vaultedge_dotnet.pid
fi

if [ -f /tmp/vaultedge_ruby.pid ]; then
    RUBY_PID=$(cat /tmp/vaultedge_ruby.pid)
    kill $RUBY_PID 2>/dev/null && echo "✓ Stopped Analyst Tools (PID: $RUBY_PID)"
    rm /tmp/vaultedge_ruby.pid
fi

# Stop MongoDB
docker-compose down
echo "✓ Stopped MongoDB"

echo ""
echo "✅ All services stopped!"
