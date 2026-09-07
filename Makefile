# Makefile — standard targets for Lab 14 (dynamic inventory).
#
#   setup    verify tools and install the Ansible collections
#   lint     terraform fmt/validate + ansible-lint
#   test     terraform validate + playbook syntax check
#   deploy   run the playbook against the dynamically discovered hosts
#   preview  show the dynamic inventory as a graph (no changes)
#   ping     SSH connectivity check against every discovered host
#   destroy  tear down the EC2 infrastructure
#   clean    remove local caches and artifacts

.PHONY: setup lint test deploy preview ping destroy clean

ANSIBLE_DIR := ansible
TERRAFORM_DIR := terraform
INVENTORY := inventory/aws_ec2.yml
PLAYBOOK := site.yml

setup:
	@echo "==> Checking required tools..."
	@command -v terraform >/dev/null 2>&1 || { echo "terraform not found — see the README prerequisites"; exit 1; }
	@command -v ansible >/dev/null 2>&1 || { echo "ansible not found — see the README prerequisites"; exit 1; }
	@command -v ansible-galaxy >/dev/null 2>&1 || { echo "ansible-galaxy not found"; exit 1; }
	@echo "==> Installing Ansible collections (amazon.aws, community.aws)..."
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml
	@echo "==> Done. Next: export AWS credentials, then 'make deploy'."

lint:
	@echo "==> terraform fmt check..."
	cd $(TERRAFORM_DIR) && terraform fmt -check -recursive
	@echo "==> terraform validate..."
	cd $(TERRAFORM_DIR) && terraform validate
	@echo "==> ansible-lint..."
	cd $(ANSIBLE_DIR) && ansible-lint site.yml

test: lint
	@echo "==> Playbook syntax check against the dynamic inventory..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check
	@echo "==> All checks passed."

preview:
	@echo "==> Discovering hosts via the amazon.aws.aws_ec2 plugin (graph view)..."
	cd $(ANSIBLE_DIR) && ansible-inventory -i $(INVENTORY) --graph

ping:
	@echo "==> Pinging all dynamically discovered hosts..."
	cd $(ANSIBLE_DIR) && ansible -i $(INVENTORY) all -m ping

deploy:
	@echo "==> Running playbook against dynamically discovered EC2 hosts..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

destroy:
	@if [ -z "$$AWS_ACCESS_KEY_ID" ] && [ -z "$$AWS_PROFILE" ]; then \
		echo "ERROR: no AWS credentials found. Export AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY or AWS_PROFILE first."; \
		exit 1; \
	fi
	@echo "==> Destroying Lab 14 infrastructure (this deletes the EC2 instance)..."
	cd $(TERRAFORM_DIR) && terraform destroy
	@echo "==> Destroyed. Verify zero resources in the AWS console."

clean:
	@echo "==> Removing local caches and artifacts (no cloud resources touched)..."
	rm -rf $(TERRAFORM_DIR)/.terraform $(TERRAFORM_DIR)/.terraform.lock.hcl
	rm -rf $(ANSIBLE_DIR)/inventory_cache $(ANSIBLE_DIR)/.ansible_cache
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f -name '*.retry' -delete
	@echo "==> Clean. Run 'make setup' before deploying again."
