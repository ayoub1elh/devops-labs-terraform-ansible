# Makefile — Lab 01: Docker provider
#
# Standard targets:
#   setup   -> check prerequisites are installed
#   lint    -> terraform fmt check
#   test    -> terraform init + validate
#   deploy  -> init / plan / apply flow
#   destroy -> tear down the container
#   clean   -> remove local Terraform working files

# Pin tool versions here so `make setup` and CI agree.
TERRAFORM ?= terraform
DOCKER    ?= docker

.PHONY: help setup lint test deploy destroy clean all

help: ## Show this help
	@echo "Lab 01 (Docker provider) targets:"
	@echo "  setup    - verify docker and terraform are installed"
	@echo "  lint     - terraform fmt -check -recursive"
	@echo "  test     - terraform init -backend=false && terraform validate"
	@echo "  deploy   - terraform init/plan/apply"
	@echo "  destroy  - terraform destroy (removes the Nginx container)"
	@echo "  clean    - remove .terraform/ and local state files"

setup: ## Check that required tools are on PATH
	@command -v $(DOCKER) >/dev/null 2>&1 || { echo "ERROR: docker not found. Install Docker Desktop (see README)."; exit 1; }
	@command -v $(TERRAFORM) >/dev/null 2>&1 || { echo "ERROR: terraform not found. Install Terraform >= 1.5 (https://developer.hashicorp.com/terraform/install)."; exit 1; }
	@$(DOCKER) info >/dev/null 2>&1 || { echo "ERROR: docker daemon is not running. Start Docker Desktop."; exit 1; }
	@echo "OK: docker $$(docker version --format '{{.Server.Version}}') and terraform $$(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4) found, daemon is up."

lint: ## terraform fmt check
	@$(TERRAFORM) fmt -check -recursive

test: ## init (local backend) + validate
	@$(TERRAFORM) init -backend=false -input=false
	@$(TERRAFORM) validate

deploy: ## terraform init / plan / apply
	@$(TERRAFORM) init -input=false
	@$(TERRAFORM) plan -out=tfplan
	@$(TERRAFORM) apply tfplan
	@echo "Deployed. Run 'terraform output url' or 'docker ps' to verify."

destroy: ## remove the container and state
	@$(TERRAFORM) destroy -auto-approve

clean: ## remove working files (keeps your *.tf sources)
	@rm -rf .terraform .terraform.lock.hcl tfplan
	@rm -f terraform.tfstate terraform.tfstate.backup crash.log
	@echo "Cleaned local Terraform working files."

all: lint test deploy ## lint + validate + deploy
