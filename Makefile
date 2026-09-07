# Makefile — local mirror of the CI pipeline: deploy -> smoke-test -> destroy.
# Run everything from the repo root (Git Bash / WSL / Linux / macOS).

TF_DIR      := terraform
ANSIBLE_DIR := ansible

.PHONY: all setup lint test deploy smoke-test ping destroy clean

## all: deploy infrastructure + configuration, then smoke-test (the full pipeline).
all: deploy smoke-test

## setup: install Terraform providers and Ansible collections.
setup:
	cd $(TF_DIR) && terraform init
	ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml
	@echo "Tip: you also need 'ansible', 'boto3' and 'botocore' (pip install ansible boto3 botocore)"

## lint: check Terraform formatting/validity and (if present) ansible-lint.
lint:
	cd $(TF_DIR) && terraform fmt -check -diff && terraform validate
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ansible-lint $(ANSIBLE_DIR)/site.yml; \
	else \
		echo "ansible-lint not installed - skipping (pip install ansible-lint)"; \
	fi

## test: alias for the local verification target.
test: smoke-test

## deploy: terraform apply, then the Ansible playbook against the dynamic inventory.
deploy:
	cd $(TF_DIR) && terraform apply -auto-approve
	ansible-playbook -i $(ANSIBLE_DIR)/inventory/aws_ec2.yml $(ANSIBLE_DIR)/site.yml

## smoke-test: curl the site and /health with retries (mirrors the CI job).
smoke-test:
	@IP=$$(cd $(TF_DIR) && terraform output -raw public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "No public_ip output found - run 'make deploy' first."; \
		exit 1; \
	fi; \
	echo "Smoke-testing http://$$IP/"; \
	curl --fail --retry 10 --retry-delay 5 --retry-connrefused "http://$$IP/"; \
	curl --fail --retry 10 --retry-delay 5 --retry-connrefused "http://$$IP/health"

## ping: quick Ansible connectivity check against the dynamic inventory.
ping:
	ansible -i $(ANSIBLE_DIR)/inventory/aws_ec2.yml all -m ping

## destroy: tear down ALL cloud resources created by this lab.
destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve

## clean: remove generated/local files only (never touches AWS).
clean:
	@echo "Removing generated inventory, Terraform plugins and caches (cloud resources untouched)."
	rm -f $(ANSIBLE_DIR)/inventory/hosts.ini
	rm -rf $(TF_DIR)/.terraform $(TF_DIR)/crash.log
	rm -rf /tmp/ansible_inventory_cache
