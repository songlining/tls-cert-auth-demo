# TLS Cert Authentication
This is the instruction for Claude Code to create a Hashicorp Vault demo flow that shows how to authenticate to Vault Enterprise with TLS Cert authentication

# Requirement
I will use my local Macbook Pro as the demo machine.  The demo will be command line based. It utilises `demo-magic.sh` to create the pace and show the vault commands.

## TLS Cert
TLS Cert to be created in the demo script and signed by Vault.  This TLS cert will be used to authenticate to Vault

## Vault Server
 - Latest Vault Enterprise server (docker image: hashicorp/vault-enterprise) will be running in a separate docker container, also run in Docker Compose.
 - License file can be found in the local directory: vault.hclic
 - Vault server will be installed, licensed and unsealed.
 - Test the installation by running `vault status`
 - After it's successfully installed and started, print out its root token and server URL so I can use on my local laptop.


## KV secret engine
KV secret engine to be enabled and populated with sample data so it can be used to prove the authentication and policy are working

# Demo Flow
Each steps below is managed by `demo-magic.sh` with its `pe` command:
- show `vault status`
- make sure the TLS certificate auth method is enabled in Vault
- shows how to create key pairs 
- using the newly created keys, request to Vault for signing (CSR).  Vault returns the TLS certificate
- configure Vault to allow the newly created TLS cert to authenticate to Vault.
- authenticate to vault
- grab the token and retrieve the KV values

# Testing
Test the demo and make sure it's all running fine, otherwise fix the error and re-test until it's working. 