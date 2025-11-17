# Media Server Kubernetes Deployment Makefile
# Automates common deployment, monitoring, and maintenance tasks

.PHONY: help deploy deploy-all deploy-shared deploy-jackett deploy-plex deploy-radarr deploy-sonarr deploy-transmission
.PHONY: status logs logs-jackett logs-plex logs-radarr logs-sonarr logs-transmission logs-vpn
.PHONY: test test-yaml test-deploy restart cleanup clean-all clean-app
.PHONY: update update-jackett update-plex update-radarr update-sonarr update-transmission
.PHONY: backup backup-config backup-secrets

# Configuration
KUBECONFIG ?= /Users/miguel/development/media-server/kubeconfig.yaml
NAMESPACE ?= media
SHELL := /bin/bash

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
help: ## Show this help message
	@echo -e "$(BLUE)Media Server Kubernetes Deployment$(NC)"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'

# Deployment targets
deploy: deploy-all ## Deploy all services (alias for deploy-all)

deploy-all: test-yaml deploy-shared ## Deploy all services with validation
	@echo -e "$(BLUE)🚀 Deploying all media server services...$(NC)"
	$(MAKE) deploy-jackett
	$(MAKE) deploy-plex
	$(MAKE) deploy-radarr
	$(MAKE) deploy-sonarr
	$(MAKE) deploy-transmission
	@echo -e "$(GREEN)✅ All services deployed successfully!$(NC)"
	$(MAKE) status

deploy-shared: ## Deploy shared resources (PVC, ConfigMaps, Secrets)
	@echo -e "$(BLUE)📦 Deploying shared resources...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f shared/
	@echo -e "$(GREEN)✅ Shared resources deployed$(NC)"

deploy-jackett: deploy-shared ## Deploy Jackett service
	@echo -e "$(BLUE)🎯 Deploying Jackett...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f jackett/
	@echo -e "$(GREEN)✅ Jackett deployed$(NC)"

deploy-plex: deploy-shared ## Deploy Plex service
	@echo -e "$(BLUE)🎬 Deploying Plex...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f plex/
	@echo -e "$(GREEN)✅ Plex deployed$(NC)"

deploy-radarr: deploy-shared ## Deploy Radarr service
	@echo -e "$(BLUE)🎬 Deploying Radarr...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f radarr/
	@echo -e "$(GREEN)✅ Radarr deployed$(NC)"

deploy-sonarr: deploy-shared ## Deploy Sonarr service
	@echo -e "$(BLUE)📺 Deploying Sonarr...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f sonarr/
	@echo -e "$(GREEN)✅ Sonarr deployed$(NC)"

deploy-transmission: deploy-shared ## Deploy Transmission service
	@echo -e "$(BLUE)⬇️  Deploying Transmission...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f transmission/
	@echo -e "$(GREEN)✅ Transmission deployed$(NC)"

# Status and monitoring
status: ## Show status of all deployments and pods
	@echo -e "$(BLUE)📊 Media Server Status$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	echo -e "\n$(YELLOW)Deployments:$(NC)" && \
	kubectl get deployments -n $(NAMESPACE) && \
	echo -e "\n$(YELLOW)Pods:$(NC)" && \
	kubectl get pods -n $(NAMESPACE) && \
	echo -e "\n$(YELLOW)Services:$(NC)" && \
	kubectl get services -n $(NAMESPACE) && \
	echo -e "\n$(YELLOW)PVCs:$(NC)" && \
	kubectl get pvc -n $(NAMESPACE)

# Logging targets
logs: logs-all ## Show logs for all services (alias for logs-all)

logs-all: ## Show logs for all running pods
	@echo -e "$(BLUE)📋 Showing logs for all services...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	for pod in $$(kubectl get pods -n $(NAMESPACE) --no-headers -o custom-columns=":metadata.name"); do \
		echo -e "\n$(YELLOW)=== Logs for $$pod ===$(NC)"; \
		kubectl logs -n $(NAMESPACE) $$pod --tail=50 || true; \
	done

logs-jackett: ## Show Jackett logs
	@echo -e "$(BLUE)🎯 Jackett Logs$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/jackett-vpn -n $(NAMESPACE)

logs-plex: ## Show Plex logs
	@echo -e "$(BLUE)🎬 Plex Logs$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/plex-kube-plex -n $(NAMESPACE)

logs-radarr: ## Show Radarr logs
	@echo -e "$(BLUE)🎬 Radarr Logs$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/radarr -n $(NAMESPACE)

logs-sonarr: ## Show Sonarr logs
	@echo -e "$(BLUE)📺 Sonarr Logs$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/sonarr -n $(NAMESPACE)

logs-transmission: ## Show Transmission logs
	@echo -e "$(BLUE)⬇️  Transmission Logs$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/transmission-vpn -n $(NAMESPACE)

logs-vpn: ## Show VPN sidecar logs for Jackett and Transmission
	@echo -e "$(BLUE)🔒 VPN Sidecar Logs$(NC)"
	@echo -e "\n$(YELLOW)=== Jackett VPN Sidecar ===$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/jackett-vpn -n $(NAMESPACE) -c vpn-sidecar &
	@echo -e "\n$(YELLOW)=== Transmission VPN Sidecar ===$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl logs -f deployment/transmission-vpn -n $(NAMESPACE) -c vpn-sidecar

# Testing targets
test: test-yaml test-deploy ## Run all tests

test-yaml: ## Validate YAML syntax for all manifests
	@echo -e "$(BLUE)🧪 Testing YAML syntax...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	find . -name "*.yaml" -exec kubectl apply --dry-run=client -f {} \; && \
	echo -e "$(GREEN)✅ All YAML files are valid$(NC)"

test-deploy: ## Test deployment with dry-run
	@echo -e "$(BLUE)🧪 Testing deployment (dry-run)...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	kubectl apply --dry-run=client -f shared/ && \
	kubectl apply --dry-run=client -f jackett/ && \
	kubectl apply --dry-run=client -f plex/ && \
	kubectl apply --dry-run=client -f radarr/ && \
	kubectl apply --dry-run=client -f sonarr/ && \
	kubectl apply --dry-run=client -f transmission/ && \
	echo -e "$(GREEN)✅ Deployment test passed$(NC)"

# Update targets
update: ## Update all services
	@echo -e "$(BLUE)🔄 Updating all services...$(NC)"
	$(MAKE) update-jackett
	$(MAKE) update-plex
	$(MAKE) update-radarr
	$(MAKE) update-sonarr
	$(MAKE) update-transmission

update-jackett: ## Update Jackett deployment
	@echo -e "$(BLUE)🔄 Updating Jackett...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f jackett/

update-plex: ## Update Plex deployment
	@echo -e "$(BLUE)🔄 Updating Plex...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f plex/

update-radarr: ## Update Radarr deployment
	@echo -e "$(BLUE)🔄 Updating Radarr...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f radarr/

update-sonarr: ## Update Sonarr deployment
	@echo -e "$(BLUE)🔄 Updating Sonarr...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f sonarr/

update-transmission: ## Update Transmission deployment
	@echo -e "$(BLUE)🔄 Updating Transmission...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl apply -f transmission/

# Restart targets
restart: ## Restart all deployments
	@echo -e "$(BLUE)🔄 Restarting all services...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	kubectl rollout restart deployment -n $(NAMESPACE)

restart-jackett: ## Restart Jackett deployment
	@echo -e "$(BLUE)🔄 Restarting Jackett...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl rollout restart deployment/jackett-vpn -n $(NAMESPACE)

restart-plex: ## Restart Plex deployment
	@echo -e "$(BLUE)🔄 Restarting Plex...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl rollout restart deployment/plex-kube-plex -n $(NAMESPACE)

restart-transmission: ## Restart Transmission deployment
	@echo -e "$(BLUE)🔄 Restarting Transmission...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl rollout restart deployment/transmission-vpn -n $(NAMESPACE)

# Cleanup targets
cleanup: clean-all ## Alias for clean-all

clean-all: ## Remove all services and shared resources
	@echo -e "$(RED)🧹 Removing all media server services...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	kubectl delete -f jackett/ --ignore-not-found=true && \
	kubectl delete -f plex/ --ignore-not-found=true && \
	kubectl delete -f radarr/ --ignore-not-found=true && \
	kubectl delete -f sonarr/ --ignore-not-found=true && \
	kubectl delete -f transmission/ --ignore-not-found=true && \
	kubectl delete -f shared/ --ignore-not-found=true && \
	echo -e "$(GREEN)✅ All services removed$(NC)"

clean-app: ## Remove specific application (usage: make clean-app APP=jackett)
	@if [ -z "$(APP)" ]; then \
		echo -e "$(RED)❌ Error: Please specify APP variable$(NC)"; \
		echo "Usage: make clean-app APP=jackett"; \
		exit 1; \
	fi
	@echo -e "$(RED)🧹 Removing $(APP)...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl delete -f $(APP)/ --ignore-not-found=true
	@echo -e "$(GREEN)✅ $(APP) removed$(NC)"

# Backup targets
backup: backup-config ## Create backups of configurations

backup-config: ## Backup all YAML configurations
	@echo -e "$(BLUE)💾 Backing up configurations...$(NC)"
	mkdir -p backup/$(shell date +%Y%m%d_%H%M%S)
	cp -r jackett/ plex/ radarr/ sonarr/ transmission/ shared/ backup/$(shell date +%Y%m%d_%H%M%S)/
	@echo -e "$(GREEN)✅ Backup created in backup/$(shell date +%Y%m%d_%H%M%S)/$(NC)"

backup-secrets: ## Backup secrets (WARNING: Contains sensitive data)
	@echo -e "$(YELLOW)⚠️  WARNING: This will backup secrets containing sensitive data!$(NC)"
	@echo -e "$(YELLOW)Press Enter to continue or Ctrl+C to cancel...$(NC)"
	@read -p ""
	mkdir -p backup/$(shell date +%Y%m%d_%H%M%S)
	export KUBECONFIG=$(KUBECONFIG) && \
	kubectl get secrets -n $(NAMESPACE) -o yaml > backup/$(shell date +%Y%m%d_%H%M%S)/secrets.yaml
	@echo -e "$(GREEN)✅ Secrets backed up$(NC)"

# Utility targets
shell: ## Open interactive shell in media namespace
	@echo -e "$(BLUE)🐚 Opening shell in $(NAMESPACE) namespace...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && kubectl exec -it -n $(NAMESPACE) deployment/jackett-vpn -- /bin/bash

vpn-test: ## Test VPN connectivity
	@echo -e "$(BLUE)🔒 Testing VPN connectivity...$(NC)"
	export KUBECONFIG=$(KUBECONFIG) && \
	echo -e "\n$(YELLOW)Jackett external IP:$(NC)" && \
	kubectl exec deployment/jackett-vpn -n $(NAMESPACE) -c jackett-vpn -- curl -s https://ipinfo.io/ip || echo "Failed to get IP" && \
	echo -e "\n$(YELLOW)Transmission external IP:$(NC)" && \
	kubectl exec deployment/transmission-vpn -n $(NAMESPACE) -c transmission-vpn -- curl -s https://ipinfo.io/ip || echo "Failed to get IP"

# Environment info
info: ## Show environment information
	@echo -e "$(BLUE)ℹ️  Environment Information$(NC)"
	@echo "KUBECONFIG: $(KUBECONFIG)"
	@echo "NAMESPACE: $(NAMESPACE)"
	@echo "KUBERNETES_VERSION: $$(export KUBECONFIG=$(KUBECONFIG) && kubectl version --client --short 2>/dev/null | head -1)"
	@echo "CLUSTER_INFO: $$(export KUBECONFIG=$(KUBECONFIG) && kubectl cluster-info 2>/dev/null | head -1)"

# Help for specific targets
help-deploy: ## Show deployment-related targets
	@echo -e "$(BLUE)Deployment Targets:$(NC)"
	@grep -E '^(deploy|test).*?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'

help-monitor: ## Show monitoring-related targets
	@echo -e "$(BLUE)Monitoring Targets:$(NC)"
	@grep -E '^(status|logs).*?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'

help-maintain: ## Show maintenance-related targets
	@echo -e "$(BLUE)Maintenance Targets:$(NC)"
	@grep -E '^(update|restart|cleanup|backup).*?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'