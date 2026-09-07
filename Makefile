# =============================================================================
# Makefile — Lab 06: Terraform Workspaces
#
# Standardized targets:
#   setup   — init Terraform and ensure dev/staging workspaces exist
#   lint    — terraform fmt -check + validate
#   test    — terraform plan for the selected workspace
#   deploy  — init + select workspace + apply (WORKSPACE=dev|staging, default dev)
#   destroy — destroy the selected workspace (asks for confirmation)
#   clean   — remove local state and plugin cache
#
# Usage:
#   make deploy              # deploys the dev workspace
#   make deploy WORKSPACE=staging
#   make destroy WORKSPACE=staging
# =============================================================================

TERRAFORM ?= terraform
WORKSPACE ?= dev

.PHONY: help setup lint test deploy destroy clean

help: ## Show this help message
	@echo "lab-06-workspaces — Terraform workspaces (dev / staging)"
	@echo ""
	@echo "Targets:"
	@echo "  setup    Initialize Terraform and create dev/staging workspaces"
	@echo "  lint     Run 'terraform fmt -check' and 'terraform validate'"
	@echo "  test     Run 'terraform plan' for WORKSPACE (default: dev)"
	@echo "  deploy   Apply the configuration to WORKSPACE (default: dev)"
	@echo "  destroy  Destroy WORKSPACE resources (default: dev)"
	@echo "  clean    Remove .terraform/ and terraform.tfstate.d/"
	@echo ""
	@echo "Variables:"
	@echo "  WORKSPACE  Workspace to act on (dev|staging), default: dev"

setup: ## Initialize Terraform and ensure both workspaces exist
	@echo "==> Running terraform init"
	@$(TERRAFORM) init
	@echo "==> Ensuring 'dev' and 'staging' workspaces exist"
	@$(TERRAFORM) workspace list | grep -qE '(^|[[:space:]])dev$$' || $(TERRAFORM) workspace new dev
	@$(TERRAFORM) workspace list | grep -qE '(^|[[:space:]])staging$$' || $(TERRAFORM) workspace new staging
	@$(TERRAFORM) workspace select $(WORKSPACE)
	@echo "==> Setup complete. Current workspace: $(WORKSPACE)"

lint: setup ## Check formatting and validate the configuration
	@echo "==> Checking formatting (terraform fmt -check -recursive)"
	@$(TERRAFORM) fmt -check -recursive
	@echo "==> Validating configuration (terraform validate)"
	@$(TERRAFORM) validate

test: setup ## Plan the current WORKSPACE without applying
	@echo "==> Planning workspace: $(WORKSPACE)"
	@$(TERRAFORM) workspace select $(WORKSPACE)
	@$(TERRAFORM) plan

deploy: setup ## Apply the configuration to WORKSPACE (default: dev)
	@echo "==> Deploying workspace: $(WORKSPACE)"
	@$(TERRAFORM) workspace select $(WORKSPACE)
	@$(TERRAFORM) apply

destroy: ## Destroy WORKSPACE resources (asks for confirmation)
	@echo "==> Destroying workspace: $(WORKSPACE)"
	@$(TERRAFORM) workspace select $(WORKSPACE)
	@$(TERRAFORM) destroy
	@echo "==> Destroyed. Repeat for the other workspace if needed:" \
		"make destroy WORKSPACE=$$([ "$(WORKSPACE)" = "dev" ] && echo staging || echo dev)"

clean: ## Remove local plugin cache and workspace state files
	@echo "==> Removing .terraform/ and terraform.tfstate.d/"
	@rm -rf .terraform terraform.tfstate.d
	@echo "==> Clean. Run 'make setup' to re-initialize."
