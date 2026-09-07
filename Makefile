# Makefile — convenience targets for lab-04-state-backends.
#
# Usage:
#   make setup    — check that required tools are installed
#   make lint     — terraform fmt check + validate (no backend credentials needed)
#   make test     — list what is in the current state backend
#   make deploy   — terraform init + apply (writes state to the active backend)
#   make migrate  — re-run init with -migrate-state (local <-> remote)
#   make destroy  — remove the managed resource
#   make clean    — remove local Terraform working files (NEVER touches remote state)

TERRAFORM ?= terraform
TF_DIR    := $(abspath .)

.PHONY: setup lint test deploy migrate destroy clean help

help: ## Show this help
	@echo "lab-04-state-backends targets:"
	@echo "  setup    Check that terraform is installed"
	@echo "  lint     fmt -check + validate (uses init -backend=false, no credentials needed)"
	@echo "  test     terraform state list (what lives in the current backend)"
	@echo "  deploy   init + plan + apply against the active backend"
	@echo "  migrate  terraform init -migrate-state (switch local <-> remote backend)"
	@echo "  destroy  terraform destroy against the active backend"
	@echo "  clean    remove .terraform/ and lock file (local only)"

setup: ## Verify required tools are available
	@command -v $(TERRAFORM) >/dev/null 2>&1 || { echo "ERROR: terraform not found. Install >= 1.5.0 from https://developer.hashicorp.com/terraform/install"; exit 1; }
	@$(TERRAFORM) version
	@echo "Setup OK. Next: edit backend.tf (replace 'your-org') and run 'make deploy'."

lint: ## terraform fmt -check + validate (no backend / cloud credentials needed)
	@$(TERRAFORM) fmt -check -recursive
	@echo "fmt OK"
	@# -backend=false skips configuring the remote backend so validate works
	@# in CI without a Terraform Cloud token.
	@$(TERRAFORM) init -backend=false -input=false >/dev/null
	@$(TERRAFORM) validate
	@echo "validate OK"

test: ## Show resources recorded in the active state backend
	@$(TERRAFORM) state list

deploy: ## init + plan + apply against the active backend
	@$(TERRAFORM) init -input=false
	@$(TERRAFORM) plan -out=tfplan
	@$(TERRAFORM) apply tfplan
	@rm -f tfplan
	@echo "Deploy complete. Run 'make test' to see what landed in state."

migrate: ## Switch between local and remote backend (edit backend.tf first!)
	@echo "Make sure you edited backend.tf (comment/uncomment the right block), then answer 'yes'."
	@$(TERRAFORM) init -migrate-state -input=false

destroy: ## terraform destroy against the active backend
	@$(TERRAFORM) destroy

clean: ## Remove local working files only (never touches remote state)
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl tfplan
	@echo "Local working files removed. Remote state (if migrated) is untouched."
