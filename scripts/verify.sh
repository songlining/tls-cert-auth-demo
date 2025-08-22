#!/bin/bash

# HashiCorp Vault TLS Certificate Authentication Demo Verification Script
# This script verifies the demo environment is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 HashiCorp Vault TLS Certificate Authentication Demo Verification${NC}"
echo "=================================================================="

# Set environment variables for HTTPS
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_CACERT='./tls/vault.crt'
export VAULT_SKIP_VERIFY='true'

# Load token if available
if [ -f ".vault-token" ]; then
    export VAULT_TOKEN=$(cat .vault-token)
fi

echo -e "${YELLOW}🔧 Checking demo environment...${NC}"
echo ""

# Check Docker containers
echo -e "${BLUE}📦 Docker Containers:${NC}"
if docker-compose ps | grep -q "vault-demo.*Up"; then
    echo -e "  ✅ Vault container is running"
else
    echo -e "  ❌ Vault container is not running"
    echo -e "     Run 'make start' to start containers"
    exit 1
fi

# Check TLS certificates
echo -e "\n${BLUE}🔐 TLS Certificates:${NC}"
if [ -f "tls/vault.crt" ] && [ -f "tls/vault.key" ]; then
    echo -e "  ✅ Vault TLS certificates exist"
else
    echo -e "  ❌ Vault TLS certificates missing"
    echo -e "     Run 'make setup' to generate certificates"
    exit 1
fi

# Check Vault status
echo -e "\n${BLUE}🏛️ Vault Status:${NC}"
if vault status &>/dev/null; then
    echo -e "  ✅ Vault is accessible"
    VAULT_STATUS=$(vault status)
    if echo "$VAULT_STATUS" | grep -q "Sealed.*false"; then
        echo -e "  ✅ Vault is unsealed"
    else
        echo -e "  ❌ Vault is sealed"
        echo -e "     Run 'make setup' to initialize and unseal Vault"
        exit 1
    fi
else
    echo -e "  ❌ Vault is not accessible"
    echo -e "     Check if containers are running with 'make status'"
    exit 1
fi

# Check authentication methods
echo -e "\n${BLUE}🔑 Authentication Methods:${NC}"
if vault auth list | grep -q "cert"; then
    echo -e "  ✅ TLS certificate auth method is enabled"
else
    echo -e "  ❌ TLS certificate auth method is not enabled"
    echo -e "     Run 'make setup' to configure authentication"
    exit 1
fi

# Check PKI secrets engine
echo -e "\n${BLUE}🏗️ PKI Infrastructure:${NC}"
if vault secrets list | grep -q "pki.*"; then
    echo -e "  ✅ PKI secrets engines are enabled"
else
    echo -e "  ❌ PKI secrets engines are not enabled"
    echo -e "     Run 'make setup' to configure PKI"
    exit 1
fi

# Check if intermediate CA is set up
if [ -f "intermediate.cert.pem" ]; then
    echo -e "  ✅ Intermediate CA certificate exists"
else
    echo -e "  ⚠️ Intermediate CA certificate missing"
    echo -e "     This will be generated during demo run"
fi

# Check demo policy
echo -e "\n${BLUE}📋 Policies:${NC}"
if vault policy list | grep -q "demo-policy"; then
    echo -e "  ✅ Demo policy exists"
else
    echo -e "  ❌ Demo policy missing"
    echo -e "     Run 'make setup' to create policies"
    exit 1
fi

# Check KV secrets engine
echo -e "\n${BLUE}📝 Secrets Engine:${NC}"
if vault secrets list | grep -q "secret.*kv"; then
    echo -e "  ✅ KV secrets engine is enabled"
    if vault kv get secret/myapp &>/dev/null; then
        echo -e "  ✅ Sample secret exists"
    else
        echo -e "  ⚠️ Sample secret missing (will be created during setup)"
    fi
else
    echo -e "  ❌ KV secrets engine is not enabled"
    echo -e "     Run 'make setup' to configure secrets engine"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All verification checks passed!${NC}"
echo ""
echo -e "${CYAN}💡 The demo environment is ready.${NC}"
echo -e "${CYAN}   Run 'make demo' to start the demonstration.${NC}"