# Makefile — standard targets for Lab 08 (Terraform CI/CD).
#
# Common targets:
#   make setup     verify tools are installed
#   make lint      fmt check + tflint (if installed)
#   make test      terraform validate
#   make deploy    init -> plan -> apply (local, using your AWS credentials)
#   make destroy   tear down the lab infrastructure
#   make clean     remove local Terraform artifacts (NEVER touches the cloud)

SHELL := /bin/bash
TF ?= terraform

.PHONY: setup lint test deploy destroy clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-12s %s\n", $$1, $$2}'

setup: ## Verify required tools are installed
	@command -v $(TF) >/dev/null 2>&1 || { echo "ERROR: terraform not found. See https://developer.hashicorp.com/terraform/install"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "ERROR: aws CLI not found. See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"; exit 1; }
	@$(TF) version
	@aws --version
	@echo "Setup OK. Run 'aws sts get-caller-identity' to confirm your credentials."

lint: ## terraform fmt check (+ tflint if available)
	@$(TF) fmt -check -recursive
	@if command -v tflint >/dev/null 2>&1; then tflint; else echo "tflint not installed - skipping (optional). Run 'make setup' docs or see https://github.com/terraform-linters/tflint"; fi

test: ## terraform validate
	@$(TF) validate

deploy: ## Local deploy: init, plan, apply (uses YOUR credentials, not CI)
	@$(TF) init -input=false
	@$(TF) plan -out=tfplan
	@$(TF) apply -input=false tfplan

destroy: ## Tear down ALL lab infrastructure (asks for confirmation)
	@echo "About to destroy the lab-08 infrastructure in AWS."
	@read -r -p "Type 'yes' to confirm: " ans; [ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }
	@$(TF) destroy

clean: ## Remove local .terraform dir, state, and plans (does NOT touch AWS)
	@echo "Removing local Terraform artifacts only (no cloud resources affected)."
	@rm -rf .terraform tfplan plan-output.txt
	@rm -f terraform.tfstate terraform.tfstate.backup
	@echo "Clean done."
