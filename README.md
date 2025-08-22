# 🔐 HashiCorp Vault TLS Certificate Authentication Demo

> **Educational Demo**: This demonstration shows how to implement TLS certificate-based authentication with HashiCorp Vault Enterprise.

## 📋 Overview

This interactive demo demonstrates:
- ✅ TLS certificate generation and signing with Vault PKI
- ✅ Certificate-based authentication to Vault
- ✅ Policy-based access control with certificates  
- ✅ Token extraction and secret retrieval
- ✅ Certificate identity verification

## 🛠️ Prerequisites

- **Docker & Docker Compose** - For running Vault Enterprise
- **HashiCorp Vault CLI** - For demo commands
- **jq** - For JSON parsing
- **OpenSSL** - For certificate operations
- **Valid Vault Enterprise License** - File named `vault.hclic` in project directory

## 🚀 Quick Start

### Complete Setup
```bash
make setup
```

### Run Interactive Demo
```bash
make demo
```

### Available Commands
```bash
make help          # Show all available commands
make start          # Start Docker containers
make stop           # Stop Docker containers  
make init           # Initialize Vault and TLS auth
make demo           # Run interactive demonstration
make verify         # Verify environment is working
make reset          # Reset demo for fresh run
make clean          # Clean up everything
make status         # Show service status
```

## 📖 Demo Flow

### Step-by-Step Demonstration

1. **🏛️ Vault Status Verification**
   - Verify Vault Enterprise is running with TLS
   - Check authentication methods

2. **🏗️ PKI Infrastructure Exploration**
   - Examine root and intermediate CA setup
   - Review certificate signing capabilities

3. **🔐 Client Certificate Generation**
   - Generate private key and CSR
   - Sign certificate with Vault's intermediate CA

4. **🔧 Authentication Configuration**
   - Configure certificate auth method
   - Apply policy-based access control

5. **🎫 Certificate Authentication**
   - Authenticate using client certificate
   - Extract authentication token

6. **📝 Secret Access**
   - Use certificate-based token
   - Retrieve secrets with proper permissions

## 🗂️ Project Structure

```
TPM-demo/
├── Makefile                    # Demo management commands
├── README.md                   # This documentation
├── docker-compose.yml          # Vault Enterprise container
├── vault-config.hcl           # Vault server configuration
├── vault.hclic                # Vault Enterprise license
├── demo.sh                    # Interactive demo script
├── generate-vault-tls.sh      # TLS certificate generation
├── scripts/
│   ├── vault-init.sh          # Vault initialization
│   ├── cleanup.sh             # Environment cleanup
│   ├── reset-demo.sh          # Demo reset for fresh runs
│   └── verify.sh              # Environment verification
└── tls/                       # Generated TLS certificates
    ├── vault.crt              # Vault server certificate
    └── vault.key              # Vault server private key
```

## 🔄 Demo Management

### Environment Lifecycle
- **Setup**: `make setup` - Complete environment initialization
- **Verify**: `make verify` - Check all components are working
- **Demo**: `make demo` - Run interactive demonstration
- **Reset**: `make reset` - Prepare for fresh demo run
- **Clean**: `make clean` - Remove all resources

### Troubleshooting
- **Check Status**: `make status` - View container and Vault status
- **Verify Setup**: `make verify` - Comprehensive environment check
- **Fresh Start**: `make clean && make setup` - Complete rebuild

## 📁 Generated Files

During demo execution, these files are created:

| File | Description |
|------|-------------|
| `CA_cert.crt` | Root CA certificate |
| `pki_intermediate.csr` | Intermediate CA signing request |
| `intermediate.cert.pem` | Signed intermediate CA certificate |
| `client.key` | Client private key |
| `client.csr` | Client certificate signing request |
| `client.crt` | Vault-signed client certificate |
| `.vault-token` | Root token (for automation) |
| `.vault-unseal-key` | Unseal key (for automation) |

## ⚙️ Configuration

### Vault Enterprise Settings
- **URL**: `https://127.0.0.1:8200`
- **TLS**: Enabled with self-signed certificates
- **Auth Method**: TLS Certificate (`auth/cert`)
- **Secrets Engine**: KV v2 at `secret/`
- **Policies**: `demo-policy` for certificate access

### Security Features
- 🔒 HTTPS-only communication
- 🔐 TLS certificate-based authentication
- 📋 Policy-based access control
- 🎫 Temporary token issuance
- 🏗️ PKI-managed certificate lifecycle

## 🎯 Use Cases Demonstrated

- **Zero-Trust Authentication**: No shared passwords or long-lived tokens
- **Certificate Lifecycle**: Automated generation and signing with Vault
- **Identity-Based Access**: Certificate DN mapped to Vault policies
- **Secure Communication**: End-to-end TLS encryption
- **Audit Trail**: All authentication attempts logged by Vault

## ⚠️ Important Notes

> This demo is designed for **educational and demonstration purposes**. 
> For production use, consider additional security measures such as:
> - Proper CA certificate management
> - Certificate revocation procedures
> - Network segmentation
> - Comprehensive audit logging
> - Regular certificate rotation