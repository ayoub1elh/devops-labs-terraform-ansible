# Makefile — Lab 03 (Modules)
#
# Standard targets for the lab. `deploy` runs the full init/plan/apply flow,
# `destroy` tears everything down. Requires terraform, docker, and curl.

.PHONY: setup lint test deploy destroy clean

setup:
	@echo "==> Checking prerequisites..."
	@terraform version
	@docker version --format 'Docker {{.Server.Version}}'
	@make --version | head -n 1
	@echo "==> All prerequisites found. See README.md for versions."

lint:
	@echo "==> Checking Terraform formatting (fmt -check -recursive)..."
	terraform fmt -check -recursive
	@echo "==> Format OK."

test:
	@echo "==> Initializing Terraform..."
	terraform init -upgrade
	@echo "==> Validating configuration..."
	terraform validate
	@echo "==> Validate OK."

deploy:
	@echo "==> Planning and applying (module instances: blue, green)..."
	terraform init
	terraform plan -out=tfplan
	terraform apply tfplan

destroy:
	@echo "==> Destroying all containers created by this lab..."
	terraform destroy

clean:
	@echo "==> Removing local Terraform artifacts (.terraform/, state, plans)..."
	rm -rf .terraform tfplan terraform.tfstate terraform.tfstate.backup crash.log
	@echo "==> Clean. Nothing remote was touched; run 'make destroy' first if needed."
