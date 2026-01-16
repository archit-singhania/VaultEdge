#!/bin/bash

# Make all scripts executable
chmod +x infra/setup.sh
chmod +x infra/start-all.sh
chmod +x infra/stop-all.sh
chmod +x infra/test-integration.sh
chmod +x infra/verify-setup.sh

echo "✅ All scripts are now executable!"
echo ""
echo "You can now run:"
echo "  ./infra/verify-setup.sh    - Check system requirements"
echo "  ./infra/setup.sh           - Install dependencies"
echo "  ./infra/start-all.sh       - Start all services"
echo "  ./infra/test-integration.sh - Run tests"
echo "  ./infra/stop-all.sh        - Stop all services"
