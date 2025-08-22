.PHONY: help start stop init demo verify clean setup status reset

help: ## Show this help message
	@echo "HashiCorp Vault TLS Certificate Authentication Demo"
	@echo "=================================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Start Docker containers
	@echo "🚀 Starting Vault Enterprise container..."
	docker-compose up -d
	@echo "✅ Container started!"

stop: ## Stop Docker containers
	@echo "🛑 Stopping Docker containers..."
	docker-compose down
	@echo "✅ Containers stopped!"

init: ## Initialize and configure Vault (run after start)
	@echo "🔧 Initializing Vault and TLS certificate authentication..."
	./scripts/vault-init.sh

demo: ## Run the interactive demo
	@echo "🎭 Starting TLS certificate authentication demo..."
	./demo.sh

reset: ## Reset demo environment for consistent runs
	@echo "🔄 Resetting demo environment..."
	./scripts/reset-demo.sh

verify: ## Verify the environment is working
	@echo "🔍 Verifying environment..."
	./scripts/verify.sh

clean: ## Clean up everything (containers, volumes, temp files)
	@echo "🧹 Cleaning up..."
	./scripts/cleanup.sh

setup: start init ## Complete setup (start + init)
	@echo "🎉 Setup complete! Run 'make demo' to start the demonstration."

status: ## Show status of all services
	@echo "📊 Service Status:"
	@echo ""
	@echo "Docker Containers:"
	@docker-compose ps
	@echo ""
	@echo "Vault Status:"
	@VAULT_ADDR=https://127.0.0.1:8200 VAULT_CACERT=./tls/vault.crt VAULT_SKIP_VERIFY=true vault status 2>/dev/null || echo "Vault not accessible"