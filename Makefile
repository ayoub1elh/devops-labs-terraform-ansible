# -----------------------------------------------------------------------------
# Makefile — Lab 02: Variables, Locals & Outputs
#
# Standard targets across all labs:
#   setup    verify prerequisites (terraform, docker)
#   lint     terraform fmt -check + tflint (if installed)
#   test     terraform validate
#   deploy   init / plan / apply
#   destroy  tear the container down
#   clean    remove local Terraform working files
# -----------------------------------------------------------------------------

.PHONY: setup lint test deploy destroy clean help

help: ## Show this help message
	@echo "Lab 02 — Variables, Locals & Outputs"
	@echo "Available targets:"
	@echo "  setup    Verify prerequisites (terraform, docker)"
	@echo "  lint     Check formatting (and tflint if installed)"
	@echo "  test     Validate the Terraform configuration"
	@echo "  deploy   Init, plan, and apply the Nginx container"
	@echo "  destroy  Tear down the container"
	@echo "  clean    Remove .terraform/ and state files (keeps tfvars)"

setup: ## Verify prerequisites
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 || { echo "ERROR: terraform not found. See https://developer.hashicorp.com/terraform/downloads"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found. Install Docker Desktop: https://www.docker.com/products/docker-desktop/"; exit 1; }
	@terraform -version
	@docker --version
	@docker info >/dev/null 2>&1 || { echo "ERROR: Docker daemon is not running. Start Docker Desktop and retry."; exit 1; }
	@echo "All prerequisites OK."

lint: ## Check Terraform formatting (and run tflint if available)
	@echo "Running terraform fmt -check..."
	terraform fmt -check -diff
	@if command -v tflint >/dev/null 2>&1; then \
		echo "Running tflint..."; \
		tflint; \
	else \
		echo "tflint not installed — skipping (install: https://github.com/terraform-linters/tflint)."; \
	fi

test: ## Validate the configuration
	@echo "Running terraform validate..."
	@terraform init -backend=false -input=false >/dev/null
	terraform validate

deploy: ## Init, plan, and apply the container
	@echo "Deploying Lab 02 Nginx container..."
	terraform init
	terraform plan -out=tfplan
	terraform apply tfplan
	@rm -f tfplan
	@echo ""
	@echo "Deployed! Try: curl $$(terraform output -raw url)"

destroy: ## Tear down the container
	@echo "Destroying Lab 02 resources..."
	terraform destroy

clean: ## Remove local Terraform artifacts (keeps terraform.tfvars)
	@echo "Removing .terraform/ and state files (this does NOT destroy cloud resources — run 'make destroy' first)..."
	rm -rf .terraform
	rm -f terraform.tfstate terraform.tfstate.* .terraform.lock.hcl
	@echo "Clean."
