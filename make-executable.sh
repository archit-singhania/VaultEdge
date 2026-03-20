#!/bin/bash

# Make all scripts executable

cd /Users/architsinghania/Documents/vaultedge

echo "Making all scripts executable..."
chmod +x infra/*.sh
chmod +x make-executable.sh

echo "✅ All scripts are now executable!"
echo ""
echo "Available scripts:"
echo "  ./infra/setup.sh            - Install dependencies"
echo "  ./infra/start-all.sh        - Start all services"
echo "  ./infra/stop-all.sh         - Stop all services"
echo "  ./infra/test-integration.sh - Run tests"
echo "  ./infra/verify-setup.sh     - Verify setup"
echo "  ./infra/check-status.sh     - Check system status"
echo "  ./infra/quick-fix.sh        - Fix Control Plane"
