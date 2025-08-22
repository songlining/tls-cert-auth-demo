#!/bin/bash

# HashiCorp Vault TLS Certificate Authentication Demo Reset Script
# This script resets the demo environment for consistent runs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 HashiCorp Vault TLS Certificate Authentication Demo Reset${NC}"
echo "==========================================================="

# Set environment variables for HTTPS
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_CACERT='./tls/vault.crt'
export VAULT_SKIP_VERIFY='true'

# Load token if available
if [ -f ".vault-token" ]; then
    export VAULT_TOKEN=$(cat .vault-token)
fi

# Check if Vault is accessible
echo -e "${YELLOW}🔍 Checking Vault accessibility...${NC}"
if ! vault status &>/dev/null; then
    echo -e "${RED}❌ Vault is not accessible. Please run 'make setup' first.${NC}"
    exit 1
fi

# Remove generated client certificates and demo files
echo -e "${YELLOW}🗑️ Removing client certificates and demo files...${NC}"
rm -f client.key
rm -f client.csr
rm -f client.crt
rm -f demo-magic.sh

# Remove any existing certificate auth configurations
echo -e "${YELLOW}🔧 Resetting certificate auth configurations...${NC}"
vault delete auth/cert/certs/demo-client 2>/dev/null || echo "No existing cert config to remove"

# Regenerate intermediate certificate if needed
if [ ! -f "intermediate.cert.pem" ]; then
    echo -e "${YELLOW}🔗 Regenerating intermediate certificate...${NC}"
    
    # Generate intermediate CSR
    vault write -format=json pki_int/intermediate/generate/internal \
        common_name="Demo Intermediate Authority" | \
        jq -r '.data.csr' > pki_intermediate.csr

    # Sign intermediate certificate
    vault write -format=json pki/root/sign-intermediate \
        csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" | \
        jq -r '.data.certificate' > intermediate.cert.pem

    # Set signed certificate
    vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
fi

echo -e "${GREEN}✅ Demo environment reset complete!${NC}"
echo ""
echo -e "${CYAN}💡 The demo environment is ready for a fresh run.${NC}"
echo -e "${CYAN}   Run 'make demo' to start the demonstration.${NC}"