#!/bin/bash

# HashiCorp Vault TLS Certificate Authentication Demo
# Using demo-magic.sh for paced demonstrations

# Download demo-magic.sh if not present
if [ ! -f "demo-magic.sh" ]; then
    echo "Downloading demo-magic.sh..."
    curl -s https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh -o demo-magic.sh
    chmod +x demo-magic.sh
fi

# Source demo-magic
. ./demo-magic.sh

# Set demo speed
TYPE_SPEED=100
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
COLOR_RESET='\033[0m'

# Set up demo environment for HTTPS
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_CACERT='./tls/vault.crt'
export VAULT_SKIP_VERIFY='true'

# Check if VAULT_TOKEN is set, if not try to load from file
if [ -z "$VAULT_TOKEN" ]; then
    if [ -f ".vault-token" ]; then
        export VAULT_TOKEN=$(cat .vault-token)
    else
        echo -e "${RED}VAULT_TOKEN not set. Please run 'make setup' first.${COLOR_RESET}"
        exit 1
    fi
fi

clear

# Demo title
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           HashiCorp Vault TLS Certificate Authentication      ║"
echo "║                            Demo                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo ""

echo -e "${YELLOW}This demo shows how to authenticate to HashiCorp Vault using TLS certificates${COLOR_RESET}"
echo ""
wait
clear

# Step 1: Show vault status
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   Step 1: Verify Vault Status                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "Let's verify that our Vault Enterprise server is running with TLS enabled:"
pe "vault status"
echo ""
echo -e "${GREEN}✅ Vault is running over HTTPS with TLS certificates${COLOR_RESET}"
wait
clear

# Step 2: Check TLS certificate auth method
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              Step 2: Verify TLS Certificate Auth Method       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🔍 Let's check if the TLS certificate authentication method is enabled:"
pe "vault auth list | grep cert"
echo ""
echo -e "${GREEN}✅ TLS certificate authentication method is enabled${COLOR_RESET}"
wait
clear

# Step 3: Show PKI infrastructure
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Step 3: Explore PKI Infrastructure             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "📋 Let's examine our PKI infrastructure for certificate management:"
pe "vault secrets list | grep pki"
echo ""
echo "🏗️ Our PKI setup includes:"
echo "  • Root CA (pki/) for signing intermediate certificates"
echo "  • Intermediate CA (pki_int/) for issuing client certificates"
wait
clear

# Step 4: Generate client private key and CSR
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              Step 4: Generate Client Private Key & CSR        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🔐 First, let's generate a private key for our client certificate:"
pe "openssl genrsa -out client.key 2048"
echo ""
echo "📝 Now create a Certificate Signing Request (CSR):"
pe "openssl req -new -key client.key -out client.csr -subj \"/CN=client.demo.local/O=Demo Org\""
echo ""
echo -e "${GREEN}✅ Client private key and CSR generated${COLOR_RESET}"
wait
clear

# Step 5: Sign the client certificate with Vault
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              Step 5: Sign Client Certificate with Vault       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "✍️ Using Vault's intermediate CA to sign our client certificate:"
pe "vault write -format=json pki_int/sign/client-role csr=@client.csr format=pem_bundle ttl=\"720h\" | jq -r '.data.certificate' > client.crt"
echo ""
echo "🔍 Let's examine the signed certificate:"
pe "openssl x509 -in client.crt -text -noout | grep -A 2 'Subject:'"
echo ""
echo -e "${GREEN}✅ Client certificate signed by Vault and ready for authentication${COLOR_RESET}"
wait
clear

# Step 6: Configure cert auth method to trust our certificate
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Step 6: Configure Certificate Authentication          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🔧 Configure the certificate auth method to trust our intermediate CA:"
pe "vault write auth/cert/certs/demo-client display_name=\"demo-client\" policies=\"demo-policy\" certificate=@intermediate.cert.pem"
echo ""
echo -e "${GREEN}✅ Certificate authentication configured to trust our CA${COLOR_RESET}"
wait
clear

# Step 7: Authenticate using the client certificate
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Step 7: Authenticate with Client Certificate        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🎫 Now let's authenticate to Vault using our client certificate:"
echo "   First, we'll configure Vault CLI to use our client certificate for TLS authentication:"
pe "export VAULT_CLIENT_CERT=\"./client.crt\""
pe "export VAULT_CLIENT_KEY=\"./client.key\""
pe "vault write -force auth/cert/login"
echo ""
echo -e "${GREEN}✅ Successfully authenticated using TLS certificate!${COLOR_RESET}"
wait
clear

# Step 8: Extract and use the authentication token
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Step 8: Extract Token and Access Secrets              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🎟️ Let's extract the authentication token from the certificate login:"
pe "CLIENT_TOKEN=\$(VAULT_CLIENT_CERT=\"./client.crt\" VAULT_CLIENT_KEY=\"./client.key\" vault write -force -format=json auth/cert/login | jq -r '.auth.client_token')"
pe "echo \"Client token: \$CLIENT_TOKEN\""
echo ""
echo "🔑 Now use this token to access secrets (switching from root token to cert token):"
pe "VAULT_TOKEN=\$CLIENT_TOKEN vault kv get secret/myapp"
echo ""
echo -e "${GREEN}✅ Successfully retrieved secrets using certificate-based authentication!${COLOR_RESET}"
wait
clear

# Step 9: Demonstrate token capabilities
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║             Step 9: Verify Token Capabilities                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo "🔍 Let's verify what capabilities our certificate-based token has:"
pe "VAULT_TOKEN=\$CLIENT_TOKEN vault token lookup"
echo ""
echo "📋 Notice the token details:"
echo "  • policies: [\"demo-policy\"] - Our certificate is assigned the demo-policy"
echo "  • entity_id: Shows this token is tied to a certificate identity"
echo "  • path: auth/cert/login - Confirms this token came from certificate auth"
wait
clear

# Demo complete
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                     Demo Complete! 🎉                         ║"
echo "║                                                               ║"
echo "║  You've successfully demonstrated:                            ║"
echo "║  • ✅ TLS certificate generation and signing with Vault PKI   ║"
echo "║  • ✅ Certificate-based authentication to Vault               ║"
echo "║  • ✅ Policy-based access control with certificates           ║"
echo "║  • ✅ Token extraction and secret retrieval                   ║"
echo "║  • ✅ Certificate identity verification                       ║"
echo "║                                                               ║"
echo "║  🔐 TLS Certificate Authentication is now working!            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
echo ""
echo -e "${CYAN}💡 Key Benefits Demonstrated:${COLOR_RESET}"
echo "  • Strong authentication using cryptographic certificates"
echo "  • No shared passwords or tokens to manage"
echo "  • Certificate-based identity tied to policies"
echo "  • Automated certificate lifecycle with Vault PKI"
echo ""