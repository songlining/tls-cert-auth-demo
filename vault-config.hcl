ui = true
disable_mlock = true

storage "inmem" {}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/tls/vault.crt"
  tls_key_file  = "/vault/config/tls/vault.key"
}