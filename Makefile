# Makefile — convenience targets for the lab-05-aws-free-tier lab.
# All Terraform operations stay local; CI never applies anything.

.PHONY: setup lint test deploy destroy clean help

# Copy the example tfvars so learners only have to edit one file.
setup:
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example — edit allowed_ssh_cidr with YOUR IP!"; \
	else \
		echo "terraform.tfvars already exists, leaving it untouched."; \
	fi

# Format check and validation. Never mutates state.
lint:
	terraform fmt -check -diff
	terraform validate

# "Tests" for IaC = plan + validate. Shows exactly what would change.
test: lint
	terraform plan -out=tfplan

# Full deploy flow: init -> plan -> apply.
deploy:
	terraform init
	terraform plan -out=tfplan
	terraform apply tfplan

# Teardown. Prompts for confirmation before destroying anything.
destroy:
	terraform destroy

# Remove local Terraform working files (never touches the cloud).
clean:
	rm -f tfplan
	rm -rf .terraform .terraform.lock.hcl

help:
	@echo "Available targets:"
	@echo "  setup    - create terraform.tfvars from the example"
	@echo "  lint     - terraform fmt -check + validate"
	@echo "  test     - lint + terraform plan (review changes, nothing applied)"
	@echo "  deploy   - terraform init + plan + apply"
	@echo "  destroy  - terraform destroy (prompts for confirmation)"
	@echo "  clean    - remove local .terraform/ and plan files"
