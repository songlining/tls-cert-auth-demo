#!/bin/bash

# HashiCorp Vault TLS Certificate Authentication Demo Initialization Script
# This script sets up Vault for TLS certificate authentication

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 HashiCorp Vault TLS Certificate Authentication Setup${NC}"
echo "======================================================="

# Generate TLS certificates if they don't exist
if [ ! -f "tls/vault.crt" ]; then
    echo -e "${YELLOW}🔐 Generating TLS certificates for Vault...${NC}"
    ./generate-vault-tls.sh
fi

# Set environment variables for HTTPS
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_CACERT='./tls/vault.crt'
export VAULT_SKIP_VERIFY='true'

# Wait for Vault to be ready
echo -e "${YELLOW}⏳ Waiting for Vault to be ready...${NC}"
sleep 10

# Check if Vault is already initialized
if vault status | grep -q "Initialized.*true"; then
    echo -e "${YELLOW}ℹ️  Vault is already initialized${NC}"
    
    # Check if we have existing tokens
    if [ -f ".vault-token" ] && [ -f ".vault-unseal-key" ]; then
        echo -e "${GREEN}✅ Using existing tokens${NC}"
        ROOT_TOKEN=$(cat .vault-token)
        UNSEAL_KEY=$(cat .vault-unseal-key)
    else
        echo -e "${RED}❌ Vault is initialized but tokens are missing${NC}"
        echo -e "${YELLOW}💡 You may need to reset Vault or provide tokens manually${NC}"
        echo -e "${YELLOW}   To reset: make clean && make setup${NC}"
        exit 1
    fi
    
    # Check if Vault is sealed
    if vault status | grep -q "Sealed.*true"; then
        echo -e "${YELLOW}🔓 Unsealing Vault...${NC}"
        vault operator unseal $UNSEAL_KEY
    else
        echo -e "${GREEN}✅ Vault is already unsealed${NC}"
    fi
else
    # Initialize vault and capture the output
    echo -e "${YELLOW}🔧 Initializing Vault...${NC}"
    INIT_OUTPUT=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
    UNSEAL_KEY=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[0]')
    ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

    # Store tokens for later use
    echo $ROOT_TOKEN > .vault-token
    echo $UNSEAL_KEY > .vault-unseal-key

    # Unseal vault
    echo -e "${YELLOW}🔓 Unsealing Vault...${NC}"
    vault operator unseal $UNSEAL_KEY
fi

# Set the root token
export VAULT_TOKEN=$ROOT_TOKEN

echo -e "${GREEN}✅ Vault is ready!${NC}"
vault status

# Enable TLS certificate auth method
echo -e "${YELLOW}🔧 Enabling TLS certificate auth method...${NC}"
vault auth enable cert 2>/dev/null || echo "TLS cert auth method already enabled"

# Enable KV secrets engine and add sample data
echo -e "${YELLOW}📝 Setting up KV secrets engine with sample data...${NC}"
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV secrets engine already enabled"
vault kv put secret/myapp username=admin password=supersecret database=production

# Enable PKI secrets engine for certificate management
echo -e "${YELLOW}🏗️ Setting up PKI infrastructure...${NC}"
vault secrets enable pki 2>/dev/null || echo "PKI secrets engine already enabled"
vault secrets tune -max-lease-ttl=87600h pki 2>/dev/null || echo "PKI secrets engine already tuned"

# Generate root CA (only if it doesn't exist)
if [ ! -f "CA_cert.crt" ] || ! vault read pki/cert/ca &>/dev/null; then
    echo -e "${YELLOW}🏛️ Generating root CA...${NC}"
    vault write -field=certificate pki/root/generate/internal \
        common_name="Demo Root CA" \
        ttl=87600h > CA_cert.crt
else
    echo -e "${GREEN}✅ Root CA already exists${NC}"
fi

# Configure CA and CRL URLs
vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Set up intermediate CA
echo -e "${YELLOW}🔗 Setting up intermediate CA...${NC}"
vault secrets enable -path=pki_int pki 2>/dev/null || echo "Intermediate PKI secrets engine already enabled"
vault secrets tune -max-lease-ttl=43800h pki_int 2>/dev/null || echo "Intermediate PKI secrets engine already tuned"

# Generate intermediate CSR and certificate (only if it doesn't exist)
if [ ! -f "intermediate.cert.pem" ] || ! vault read pki_int/cert/ca &>/dev/null; then
    echo -e "${YELLOW}🔗 Generating intermediate CA...${NC}"
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
else
    echo -e "${GREEN}✅ Intermediate CA already exists${NC}"
fi

# Create a role for client certificates
echo -e "${YELLOW}👤 Creating client certificate role...${NC}"
vault write pki_int/roles/client-role \
    allowed_domains="demo.local" \
    allow_subdomains=true \
    max_ttl="720h" \
    client_flag=true 2>/dev/null || echo "Client role already exists"

echo -e "${GREEN}✅ PKI infrastructure configured!${NC}"

# Create a policy for certificate authentication
echo -e "${YELLOW}📋 Creating demo policy...${NC}"
vault policy write demo-policy - <<EOF
path "secret/data/myapp" {
  capabilities = ["read"]
}

path "secret/metadata/myapp" {
  capabilities = ["read"]
}
EOF

echo -e "${GREEN}🎉 Initialization complete!${NC}"
echo ""
echo -e "${YELLOW}💡 Environment Variables for Demo:${NC}"
echo "=================================="
echo "export VAULT_ADDR='https://127.0.0.1:8200'"
echo "export VAULT_CACERT='./tls/vault.crt'"
echo "export VAULT_SKIP_VERIFY='true'"
echo "export VAULT_TOKEN='$ROOT_TOKEN'"
echo ""
echo -e "${BLUE}Demo Information:${NC}"
echo "=================="
echo -e "Vault URL: ${GREEN}https://127.0.0.1:8200${NC}"
echo -e "Root Token: ${GREEN}$ROOT_TOKEN${NC}"
echo -e "Unseal Key: ${GREEN}$UNSEAL_KEY${NC}"
echo ""
echo -e "${YELLOW}🎭 Ready to run demo: make demo${NC}"