#!/bin/bash

# HashiCorp Vault TLS Certificate Authentication Demo Cleanup Script
# This script cleans up all demo resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 HashiCorp Vault TLS Certificate Authentication Demo Cleanup${NC}"
echo "=============================================================="

# Stop and remove Docker containers
echo -e "${YELLOW}🛑 Stopping and removing Docker containers...${NC}"
docker-compose down -v 2>/dev/null || echo "No containers to stop"

# Remove generated certificates and keys
echo -e "${YELLOW}🗑️ Removing generated certificates and keys...${NC}"
rm -f CA_cert.crt
rm -f pki_intermediate.csr
rm -f intermediate.cert.pem
rm -f client.key
rm -f client.csr
rm -f client.crt
rm -f .vault-token
rm -f .vault-unseal-key

# Remove TLS directory
echo -e "${YELLOW}🔐 Removing TLS certificates...${NC}"
rm -rf tls/

# Remove demo-magic.sh if it was downloaded
if [ -f "demo-magic.sh" ]; then
    echo -e "${YELLOW}📜 Removing downloaded demo-magic.sh...${NC}"
    rm -f demo-magic.sh
fi

# Remove Docker volumes
echo -e "${YELLOW}📦 Removing Docker volumes...${NC}"
docker volume prune -f 2>/dev/null || echo "No volumes to remove"

# Remove Docker networks
echo -e "${YELLOW}🌐 Removing Docker networks...${NC}"
docker network prune -f 2>/dev/null || echo "No networks to remove"

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo -e "${CYAN}💡 All demo resources have been removed.${NC}"
echo -e "${CYAN}   Run 'make setup' to start fresh.${NC}"