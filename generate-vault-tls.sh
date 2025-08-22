#!/bin/bash

# Create TLS directory
mkdir -p tls

# Generate private key for Vault server
openssl genrsa -out tls/vault.key 2048

# Generate certificate signing request
openssl req -new -key tls/vault.key -out tls/vault.csr -subj "/C=US/ST=CA/L=San Francisco/O=HashiCorp/OU=Vault/CN=localhost" -config <(
cat <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = CA
L = San Francisco
O = HashiCorp
OU = Vault
CN = localhost

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = vault
DNS.3 = 127.0.0.1
IP.1 = 127.0.0.1
EOF
)

# Generate self-signed certificate
openssl x509 -req -in tls/vault.csr -signkey tls/vault.key -out tls/vault.crt -days 365 -extensions v3_req -extfile <(
cat <<EOF
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = vault
DNS.3 = 127.0.0.1
IP.1 = 127.0.0.1
EOF
)

echo "TLS certificates generated in tls/ directory"